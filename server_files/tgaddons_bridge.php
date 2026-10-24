<?php
/**
 * Litrex Telegram PDF Monitor Bridge v1.0
 * 100% Güvenli, Bağımsız ve Tamamen Pulsuz Eklenti Köprüsü
 */

error_reporting(0);
ini_set('display_errors', 0);
set_time_limit(60);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: *');

$action = $_GET['action'] ?? 'dashboard';

$host = $_SERVER['HTTP_HOST'] ?? 'olibrary.space';
$protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$base_url = "{$protocol}://{$host}";

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

// Oxuma və Cover axınları üçün yüngülləşdirilmiş yoxlanış
if ($action === 'read' || $action === 'cover') {
    if (strpos($user_agent, 'LitrexOfficialApp') === false && strpos($user_agent, 'Dart') === false) {
        http_response_code(403);
        echo json_encode(["error" => "Erişim engellendi. Bu işlem için yetkiniz yok."], JSON_UNESCAPED_UNICODE);
        exit;
    }
} else {
    // Katalog məlumatları üçün ciddi yoxlanış
    if ($app_key !== 'Litrex_Secret_Addon_Token_2026_Secure' || strpos($user_agent, 'LitrexOfficialApp') === false) {
        http_response_code(403);
        echo json_encode(["error" => "Erişim reddedildi. Yetkisiz istemci."], JSON_UNESCAPED_UNICODE);
        exit;
    }
}
// ==================== TƏHLÜKƏSİZLİK YOXLANIŞININ SONU ============

// ==================== UZAQ SERVER (PDF MONITOR API) ====================
// PDF Monitor Litrex serverindədir, Bridge isə olibrary.space-də.
$remote_api = "http://159.195.71.32:5000";

// Bütün pdf arxivini API-dən çəkir
function fetchRemotePDFs() {
    global $remote_api;
    $url = $remote_api . "/api/pdfs";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 15);
    $response = curl_exec($ch);
    curl_close($ch);
    
    if (!$response) return [];
    
    $data = json_decode($response, true);
    return is_array($data) ? $data : [];
}

$books_data = fetchRemotePDFs();

// Load authors database from pdfmonitor for missing author bios and photos
$authors_db = [];
$authors_file = __DIR__ . '/../../pdfmonitor/authors.json'; // relative path based on AAPanel structure
$raw_content = file_exists($authors_file) ? file_get_contents($authors_file) : false;
if (!$raw_content) {
    // fallback absolute path
    $authors_file_abs = "C:\\litresfer\\Litrex-main (12)\\pdfmonitor\\authors.json";
    $raw_content = file_exists($authors_file_abs) ? file_get_contents($authors_file_abs) : false;
}

if ($raw_content) {
    // Fix Unicode NFD vs NFC issue for Turkish characters (e.g. ü vs ü)
    $nfd_to_nfc = [
        "u\xcc\x88" => "ü", "U\xcc\x88" => "Ü",
        "o\xcc\x88" => "ö", "O\xcc\x88" => "Ö",
        "c\xcc\xa7" => "ç", "C\xcc\xa7" => "Ç",
        "s\xcc\xa7" => "ş", "S\xcc\xa7" => "Ş",
        "g\xcc\x86" => "ğ", "G\xcc\x86" => "Ğ",
        "I\xcc\x87" => "İ"
    ];
    $raw_content = strtr($raw_content, $nfd_to_nfc);
    $authors_db = json_decode($raw_content, true) ?: [];
}

// YALNIZ Admin tərəfindən təsdiqlənmiş (Litrexdə Var və ya manual_litrex işarələnmiş) kitabları eklentidə göstər
$approved_books = [];
foreach ($books_data as $entry) {
    if (!empty($entry['litrex_exists']) || !empty($entry['manual_litrex'])) {
        $approved_books[] = $entry;
    }
}
$books_data = $approved_books;

// Kateqoriya Xəritələnməsi (PDF Monitor -> Litrex)
function mapPdfMonitorCategory($catName) {
    $catName = strtolower(trim($catName));
    switch ($catName) {
        case 'romantik':
            return ["id" => "1", "name" => "Romantik"];
        case 'korku-gerilim':
        case 'dedektifler':
            return ["id" => "4", "name" => "Korku-Gerilim"];
        case 'fantastik':
            return ["id" => "5", "name" => "Fantastik"];
        case 'asker kurgusu':
        case 'mahalle kurgusu':
        case 'gençlik':
            return ["id" => "9", "name" => "Gençlik"];
        default:
            return ["id" => "10", "name" => "Roman"];
    }
}

// PDF Monitor Kitabını Litrex formatına çevirir
function transformPdfBook($entry) {
    global $base_url;
    $id = $entry['id'];
    $filename = $entry['filename'];
    
    if (!empty($entry['book_info'])) {
        $info = $entry['book_info'];
        $cat = mapPdfMonitorCategory($info['category'] ?? 'Roman');
        
        $cover = $base_url . '/banner.jpg';
        if (!empty($entry['litrex_cover'])) {
            $cover = $entry['litrex_cover'];
        } elseif (!empty($info['cover'])) {
            if (preg_match('/^http/i', $info['cover'])) {
                $cover = $info['cover'];
            } else {
                $cover = $base_url . "/tgaddons_bridge.php?action=cover&filename=" . rawurlencode(basename($info['cover']));
            }
        }
        
        // Kanal adını eklenti kimi göstərmək üçün
        $channel = $entry['channel_name'] ?? 'TGAddons';
        $author_name_raw = $info['author'] ?? 'Naməlum Yazar';

        // Extract author photo and bio
        $author_image = $info['author_photo'] ?? ($info['author_info']['photo'] ?? '');
        $author_bio = $info['author_bio'] ?? ($info['author_info']['bio'] ?? '');

        // Fetch from authors_db if missing
        global $authors_db, $remote_api;
        if (isset($authors_db[$author_name_raw])) {
            if (empty($author_image) && !empty($authors_db[$author_name_raw]['photo'])) {
                $author_image = $authors_db[$author_name_raw]['photo'];
            }
            if (empty($author_bio) && !empty($authors_db[$author_name_raw]['bio'])) {
                $author_bio = $authors_db[$author_name_raw]['bio'];
            }
        }

        // Prepend remote API base URL if author image is a relative path from pdfmonitor
        if (!empty($author_image) && !preg_match('/^http/i', $author_image)) {
            $author_image = rtrim($remote_api, '/') . '/' . ltrim($author_image, '/');
        }

        return [
            "id" => "pdfmon_" . $id,
            "name" => $info['title'] ?? str_replace('.pdf', '', $filename),
            "category_id" => $cat['id'],
            "category_name" => $cat['name'],
            "author_name" => $author_name_raw . " \n(Eklenti: {$channel})",
            "author_image" => $author_image,
            "author_bio" => $author_bio,
            "logo" => $cover,
            "is_premium" => "1",
            "coin_price" => isset($info['coin_price']) && (int)$info['coin_price'] > 0 ? (int)$info['coin_price'] : 50,
            "type" => "pdf",
            "file" => $base_url . "/tgaddons_bridge.php?action=read&filename=" . rawurlencode($filename),
            "description" => !empty($info['desc']) ? $info['desc'] : 'Bu kitab Telegram PDF Monitor tərəfindən avtomatik olaraq əlavə edilib.'
        ];
    } else {
        // Claude tərəfindən hələ işlənməyən kitablar üçün xam versiya
        $clean_title = str_replace('.pdf', '', $filename);
        $clean_title = str_replace('.PDF', '', $clean_title);
        $clean_title = preg_replace('/-\s*\(zm\).*/i', '', $clean_title);
        $channel = $entry['channel_name'] ?? 'TGAddons';

        $cover = $base_url . '/banner.jpg';
        if (!empty($entry['litrex_cover'])) {
            $cover = $entry['litrex_cover'];
        }

        return [
            "id" => "pdfmon_" . $id,
            "name" => trim($clean_title),
            "category_id" => "10",
            "category_name" => "Roman",
            "author_name" => "Naməlum Yazar \n(Eklenti: {$channel})",
            "logo" => $cover,
            "is_premium" => "1",
            "coin_price" => 50,
            "type" => "pdf",
            "file" => $base_url . "/tgaddons_bridge.php?action=read&filename=" . rawurlencode($filename),
            "description" => 'Bu kitab Telegram PDF Monitor vasitəsilə tətbiqə integurasiya olunub.'
        ];
    }
}

// ==================== DASHBOARD ====================
if ($action === 'dashboard') {
    // Sıralama məntiqi (Admin paneldəki kimi: litrex_id DESC, litrex_added_date DESC, date DESC)
    usort($books_data, function($a, $b) {
        $idA = isset($a['litrex_id']) ? (int)$a['litrex_id'] : 0;
        $idB = isset($b['litrex_id']) ? (int)$b['litrex_id'] : 0;
        
        if ($idA && $idB) return $idB - $idA;
        if ($idA && !$idB) return -1;
        if (!$idA && $idB) return 1;
        
        $dateA = $a['litrex_added_date'] ?? $a['date'] ?? "";
        $dateB = $b['litrex_added_date'] ?? $b['date'] ?? "";
        return strcmp($dateB, $dateA);
    });

    $processed_books = [];
    foreach ($books_data as $entry) {
        $processed_books[] = transformPdfBook($entry);
    }
    // Slizer, Populyar və Öne Çıxan kitabların bölünməsi
    // Limitlər azaldıldı ki, tətbiq donmasın (Təhlükəsiz rəqəmlər)
    $latest = array_slice($processed_books, 0, 30);
    $popular = array_slice($processed_books, 30, 15);
    $featured = array_slice($processed_books, 45, 15);
    
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
            ["id" => "pdfmon_slide_1", "title" => "Telegram Kitaplığınız", "image" => $base_url . "/banner.jpg"]
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

// ==================== ARAMA ====================
if ($action === 'search') {
    $q = $_GET['q'] ?? '';
    
    // Flutter tətbiqi axtarışa yazar adını göndərəndə yanında "\n(Eklenti: ...)" hissəsi də olur. Onu təmizləyirik.
    $q = preg_replace('/\s*\(Eklenti:.*?\)/i', '', $q);
    $q = mb_strtolower(trim($q), 'UTF-8');
    
    $matches = [];
    foreach ($books_data as $entry) {
        $id = $entry['id'];
        $full_id = "pdfmon_" . $id;
        $title = $entry['book_info']['title'] ?? $entry['filename'];
        $author = $entry['book_info']['author'] ?? '';
        $desc = $entry['book_info']['desc'] ?? '';
        
        $title_lower = mb_strtolower($title, 'UTF-8');
        $author_lower = mb_strtolower($author, 'UTF-8');
        $desc_lower = mb_strtolower($desc, 'UTF-8');
        
        if (empty($q) || 
            mb_strpos($title_lower, $q, 0, 'UTF-8') !== false || 
            mb_strpos($author_lower, $q, 0, 'UTF-8') !== false || 
            mb_strpos($desc_lower, $q, 0, 'UTF-8') !== false ||
            $q === mb_strtolower($full_id, 'UTF-8') ||
            $q === (string)$id) {

            
            $matches[] = transformPdfBook($entry);
        }
    }
    
    // Axtarış üçün 50 kitaba qədər göstərək
    echo json_encode(["data" => array_slice($matches, 0, 50)], JSON_UNESCAPED_UNICODE);
    exit;
}

// ==================== KATEGORİ ====================
if ($action === 'category') {
    $catId = $_GET['cat_id'] ?? '';
    
    $matches = [];
    foreach ($books_data as $entry) {
        $book = transformPdfBook($entry);
        if ($book['category_id'] === $catId) {
            $matches[] = $book;
        }
    }
    
    // Kateqoriya üçün 50 kitaba qədər göstərək
    echo json_encode(["data" => array_slice($matches, 0, 50)], JSON_UNESCAPED_UNICODE);
    exit;
}

// ==================== PDF OKUMA OKUYUCUSU (Secure Stream) ====================
if ($action === 'read') {
    $filename = $_GET['filename'] ?? '';
    $filename = basename($filename); // Directory traversal hücumundan müdafiə
    
    $remote_url = $remote_api . "/api/download/" . rawurlencode($filename);
    
    header("Content-Type: application/pdf");
    header('Content-Disposition: inline; filename="' . $filename . '"');
    
    // Remote stream
    @readfile($remote_url);
    exit;
}

// ==================== COVER ÜZ QABIĞI (Secure Stream) ====================
if ($action === 'cover') {
    $filename = $_GET['filename'] ?? '';
    $filename = basename($filename);
    
    $remote_url = $remote_api . "/api/covers/" . rawurlencode($filename);
    
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    $mime = ($ext === 'png') ? 'image/png' : 'image/jpeg';
    
    header("Content-Type: " . $mime);
    
    // Remote stream
    @readfile($remote_url);
    exit;
}

echo json_encode(["error" => "Geçersiz işlem"]);
?>
