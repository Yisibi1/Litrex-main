<?php
/**
 * Booksfer Bridge for Litrex Addon
 * MySQL Remote connection to Booksfer database
 * Outputs data in standard Litrex format with strict token verification
 */

error_reporting(0);
ini_set('display_errors', 0);
set_time_limit(60);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: *');

$action = $_GET['action'] ?? 'dashboard';

// ==================== TƏHLÜKƏSİZLİK YOXLANIŞI ====================
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

$app_key = $_SERVER['HTTP_X_OLIBRARY_KEY'] ?? '';
if (empty($app_key) && function_exists('getallheaders')) {
    $headers = getallheaders();
    $headers_lower = array_change_key_case($headers, CASE_LOWER);
    $app_key = $headers_lower['x-olibrary-key'] ?? '';
}

$user_agent = $_SERVER['HTTP_USER_AGENT'] ?? '';

// PDF yükləmə sorğusu üçün yüngülləşdirilmiş yoxlanış
if ($action === 'read') {
    if (strpos($user_agent, 'LitrexOfficialApp') === false && strpos($user_agent, 'Dart') === false) {
        http_response_code(403);
        echo json_encode(["error" => "Erişim engellendi. Bu işlem için yetkiniz yok."], JSON_UNESCAPED_UNICODE);
        exit;
    }
} else {
    // Dashboard, Arama və Kateqoriya üçün ciddi yoxlanış
    if ($app_key !== 'Litrex_Secret_Addon_Token_2026_Secure' || strpos($user_agent, 'LitrexOfficialApp') === false) {
        http_response_code(403);
        echo json_encode(["error" => "Erişim reddedildi. Yetkisiz istemci."], JSON_UNESCAPED_UNICODE);
        exit;
    }
}
// ==================== TƏHLÜKƏSİZLİK YOXLANIŞININ SONU ============

// Verilənlər Bazası Qoşulması
function getBooksferDB() {
    static $conn = null;
    if ($conn === null) {
        mysqli_report(MYSQLI_REPORT_OFF);
        $conn = @new mysqli('159.195.71.32', 'hecer2', 'hecer', 'hecer2');
        if ($conn->connect_error) {
            $conn = false;
            return null;
        }
        $conn->set_charset("utf8mb4");
    }
    return $conn === false ? null : $conn;
}

// Kateqoriya Xəritələnməsi (Booksfer -> Litrex)
function mapBooksferCategory($booksferCatId) {
    $mapping = [
        1 => "10",   // Roman / Kitaplar
        2 => "10",   // Genel
        79 => "9",   // 1-ci sinif -> Gençlik
        80 => "9",   // 2-ci sinif -> Gençlik
        88 => "9",   // 10-cu sinif -> Gençlik
        89 => "9",   // 11-ci sinif -> Gençlik
        90 => "9",   // 12-ci sinif -> Gençlik
    ];
    return $mapping[$booksferCatId] ?? "10";
}

// Kateqoriya Xəritələnməsi (Litrex -> Booksfer)
function getBooksferCategoryIdsForLitrex($litrexCatId) {
    $map = [
        "1" => [1], // Romantik
        "4" => [1], // Korku-Gerilim
        "5" => [1], // Fantastik
        "9" => [79, 80, 88, 89, 90], // Gençlik/Sınıflar
        "10" => [1], // Roman
    ];
    return $map[$litrexCatId] ?? [];
}

// Kitabların Çəkilməsi
function fetchBooksferBooks($limit = 10, $categoryId = null, $searchQuery = null) {
    $db = getBooksferDB();
    if (!$db) return [];
    
    $sql = "SELECT p.id, p.slug, p.category_id, p.price, p.is_free_product, p.image_cache, pd.title, pd.description,
            (SELECT cl.name FROM category_lang cl WHERE cl.category_id = p.category_id AND cl.lang_id = 3 LIMIT 1) as category_name
            FROM products p
            JOIN product_details pd ON p.id = pd.product_id
            WHERE p.status = 1 AND p.is_deleted = 0 AND p.is_draft = 0 AND p.product_type = 'digital' AND pd.lang_id = 3";
            
    if ($categoryId !== null) {
        $catIds = getBooksferCategoryIdsForLitrex($categoryId);
        if (!empty($catIds)) {
            $sql .= " AND p.category_id IN (" . implode(',', array_map('intval', $catIds)) . ")";
        } else {
            $sql .= " AND p.category_id = 1";
        }
    }
    
    if ($searchQuery !== null) {
        $searchEscaped = $db->real_escape_string($searchQuery);
        if (strpos($searchQuery, 'booksfer_') === 0) {
            $real_id = intval(str_replace('booksfer_', '', $searchQuery));
            $sql .= " AND p.id = $real_id";
        } else {
            $sql .= " AND (pd.title LIKE '%$searchEscaped%' OR pd.description LIKE '%$searchEscaped%')";
        }
    }
    
    $sql .= " ORDER BY p.id DESC LIMIT " . intval($limit);
    
    $result = $db->query($sql);
    if (!$result) return [];
    
    $books = [];
    while ($row = $result->fetch_assoc()) {
        $p_id = $row['id'];
        
        // Yazar adını çəkmək (field_id = 1 Author custom field-dir)
        $author_sql = "SELECT 
            COALESCE(
                (SELECT opt.name FROM custom_field_option_lang opt JOIN custom_fields_product cfp ON opt.option_id = cfp.selected_option_id WHERE cfp.product_id = $p_id AND cfp.field_id = 1 AND opt.lang_id = 3 LIMIT 1),
                (SELECT cfp.field_value FROM custom_fields_product cfp WHERE cfp.product_id = $p_id AND cfp.field_id = 1 LIMIT 1),
                'Bilinmeyen Yazar'
            ) AS author_name";
        $author_res = $db->query($author_sql);
        $author_row = $author_res ? $author_res->fetch_assoc() : null;
        $author_name = $author_row ? $author_row['author_name'] : 'Bilinmeyen Yazar';
        
        // Şəkil URL-i
        $cover_url = '';
        if (!empty($row['image_cache'])) {
            $images = json_decode($row['image_cache'], true);
            if (!empty($images) && isset($images[0]['image'])) {
                $img_path = $images[0]['image'];
                $storage = $images[0]['storage'] ?? 'local';
                if ($storage === 'aws_s3') {
                    $cover_url = "https://booksfer-cdn.sgp1.digitaloceanspaces.com/uploads/images/" . $img_path;
                } else {
                    $cover_url = "https://booksfer.net/uploads/images/" . $img_path;
                }
            }
        }
        
        // Kitab adından "| PDF İndir", "|PDF İNDİR" kimi şəkilçiləri sil
        $clean_title = preg_replace('/\s*\|?\s*pdf\s*(indir|İndir|İNDİR|download|indir\.?)?.*$/ui', '', $row['title']);
        $clean_title = trim($clean_title, " \t\n\r-|");
        
        $books[] = [
            "id" => "booksfer_" . $p_id,
            "name" => $clean_title,
            "category_id" => mapBooksferCategory($row['category_id']),
            "category_name" => $row['category_name'] ?? 'Genel',
            "author_name" => $author_name,
            "logo" => $cover_url,
            "is_premium" => "0",
            "coin_price" => 0,
            "type" => "pdf",
            "file" => "https://olibrary.space/booksfer_bridge.php?action=read&id=booksfer_" . $p_id . "&ext=.pdf",
            "description" => preg_replace('/\s*\|?\s*pdf\s*(indir|İndir|İNDİR|download)?[,.]?\s*/ui', ' ', strip_tags($row['description'] ?? 'Booksfer üzerinden çekilmiştir.'))
        ];
    }
    
    return $books;
}

// ==================== ACTIONS ====================

// 1. DASHBOARD
if ($action === 'dashboard') {
    $latest = fetchBooksferBooks(8);
    $popular = fetchBooksferBooks(10);
    $featured = fetchBooksferBooks(6);
    
    // Gündəlik reklam limitini Litrex Admin API-dən oxu
    $daily_ad_limit = 15; // default
    $cfg_ch = curl_init();
    curl_setopt($cfg_ch, CURLOPT_URL, "http://159.195.71.32/api/coins/app-settings.php");
    curl_setopt($cfg_ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($cfg_ch, CURLOPT_TIMEOUT, 5);
    $cfg_resp = curl_exec($cfg_ch);
    curl_close($cfg_ch);
    if ($cfg_resp) {
        $cfg_data = json_decode($cfg_resp, true);
        if (isset($cfg_data['daily_ad_limit'])) {
            $daily_ad_limit = (int)$cfg_data['daily_ad_limit'];
        }
    }

    $response = [
        "slider" => [
            ["id" => "bs_1", "title" => "Booksfer Kitaplığı", "image" => "https://olibrary.space/banner.jpg"]
        ],
        "category" => [
            ["id" => "1", "name" => "Romantik", "logo" => ""],
            ["id" => "4", "name" => "Korku-Gerilim", "logo" => ""],
            ["id" => "5", "name" => "Fantastik", "logo" => ""],
            ["id" => "9", "name" => "Gençlik", "logo" => ""],
            ["id" => "10", "name" => "Roman", "logo" => ""]
        ],
        "latest_book" => $latest,
        "popular_book" => $popular,
        "featured_book" => $featured,
        "daily_ad_limit" => $daily_ad_limit
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit;
}

// 2. SEARCH
if ($action === 'search') {
    $q = $_GET['q'] ?? '';
    if (empty($q)) {
        echo json_encode(["data" => []]);
        exit;
    }
    
    $books = fetchBooksferBooks(15, null, $q);
    echo json_encode(["data" => $books], JSON_UNESCAPED_UNICODE);
    exit;
}

// 3. CATEGORY
if ($action === 'category') {
    $catId = $_GET['cat_id'] ?? '';
    $books = fetchBooksferBooks(15, $catId);
    echo json_encode(["data" => $books], JSON_UNESCAPED_UNICODE);
    exit;
}

// 4. READ
if ($action === 'read') {
    $id = $_GET['id'] ?? '';
    if (empty($id)) {
        echo json_encode(["error" => "ID belirtilmedi"]);
        exit;
    }
    
    $real_id = intval(str_replace('booksfer_', '', $id));
    $db = getBooksferDB();
    if ($db) {
        $sql = "SELECT file_name, storage FROM digital_files WHERE product_id = " . $real_id . " LIMIT 1";
        $res = $db->query($sql);
        if ($res && $row = $res->fetch_assoc()) {
            $file_name = $row['file_name'];
            $storage = $row['storage'] ?? 'local';
            if ($storage === 'aws_s3') {
                $file_url = "https://booksfer-cdn.sgp1.digitaloceanspaces.com/uploads/digital-files/" . $file_name;
            } else {
                $file_url = "https://booksfer.net/uploads/digital-files/" . $file_name;
            }
            header("Location: " . $file_url);
            exit;
        }
    }
    
    http_response_code(404);
    echo "Hata: Dosya bulunamadı.";
    exit;
}

echo json_encode(["error" => "Geçersiz işlem"]);
?>
