<?php
/**
 * Litrex Wattpad Bridge v26.0
 * Tamamen Türkçe filtrelenmiş sonuçlar (language=23)
 * Server-taraflı dil doğrulaması ile çift güvenlik
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

$cache_dir = __DIR__ . '/cache';

if (!is_dir($cache_dir)) {
    mkdir($cache_dir, 0777, true);
}

// cURL yardımcı fonksiyonu
function fetchWattpad($url) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 20);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Accept-Language: tr-TR,tr;q=0.9'
    ]);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}

// Wattpad türlerini Litrex kategorilerine eşler
function mapWattpadCategory($catIds) {
    if (empty($catIds)) return ["category_id" => "10", "category_name" => "Roman"];
    
    $firstCat = is_array($catIds) ? ($catIds[0] ?? 0) : $catIds;
    
    $mapping = [
        1 => ["id" => "9", "name" => "Gençlik"],
        2 => ["id" => "10", "name" => "Şiir"],
        3 => ["id" => "5", "name" => "Fantastik"],
        4 => ["id" => "1", "name" => "Romantik"],
        5 => ["id" => "10", "name" => "Klasik"],
        6 => ["id" => "5", "name" => "Fantastik"],
        7 => ["id" => "4", "name" => "Korku-Gerilim"],
        9 => ["id" => "9", "name" => "Tarih"],
        10 => ["id" => "4", "name" => "Korku-Gerilim"],
        14 => ["id" => "4", "name" => "Korku-Gerilim"],
        17 => ["id" => "5", "name" => "Fantastik"],
        18 => ["id" => "5", "name" => "Fantastik"]
    ];
    
    if (isset($mapping[$firstCat])) {
        return ["category_id" => $mapping[$firstCat]["id"], "category_name" => $mapping[$firstCat]["name"]];
    }
    
    return ["category_id" => "10", "category_name" => "Roman"];
}

// Wattpad nesnesini Litrex Book modeline dönüştürür
function transformBook($wp) {
    $cat = mapWattpadCategory($wp['categories'] ?? []);
    
    return [
        "id" => (string)$wp['id'],
        "name" => $wp['title'] ?? 'Bilinmeyen Kitap',
        "category_id" => $cat['category_id'],
        "category_name" => $cat['category_name'],
        "author_name" => $wp['user']['name'] ?? $wp['user']['username'] ?? 'Wattpad Yazarı',
        "logo" => $wp['cover'] ?? '',
        "is_premium" => "0",
        "coin_price" => 0,
        "type" => "pdf",
        "file" => "https://olibrary.space/bridge.php?action=read&id=" . $wp['id'] . "&ext=.pdf",
        "description" => strip_tags($wp['description'] ?? 'Bu kitap Wattpad üzerinden dinamik olarak çekilmiştir.')
    ];
}

/**
 * DİL FİLTRESİ: Yalnızca Türkçe (language.id=23) kitapları döndürür.
 * Çift güvenlik: API parametresi + sunucu taraflı kontrol
 */
function filterTurkishOnly($stories) {
    if (empty($stories) || !is_array($stories)) return [];
    $filtered = [];
    foreach ($stories as $wp) {
        $langId = $wp['language']['id'] ?? null;
        // 23 = Türkçe, null = dil bilgisi yoksa da kabul et (language field istenmemişse)
        if ($langId === 23 || $langId === '23' || $langId === null) {
            $filtered[] = $wp;
        }
    }
    return $filtered;
}

/**
 * Wattpad'den Türkçe kitapları çeker (language=23 + server filtresi)
 */
function fetchTurkishBooks($query, $minCount = 6) {
    $allBooks = [];
    $offset = 0;
    $maxAttempts = 3;
    $limit = max($minCount * 2, 15);
    
    for ($i = 0; $i < $maxAttempts && count($allBooks) < $minCount; $i++) {
        $url = "https://www.wattpad.com/v4/search/stories?query=" . urlencode($query) 
             . "&limit=" . $limit 
             . "&language=23"
             . "&offset=" . $offset
             . "&fields=stories(id,title,cover,description,user(name,username),categories,language(id))";
        
        $res = fetchWattpad($url);
        if (!isset($res['stories']) || empty($res['stories'])) break;
        
        $turkishOnly = filterTurkishOnly($res['stories']);
        $allBooks = array_merge($allBooks, $turkishOnly);
        
        $offset += $limit;
    }
    
    return array_slice($allBooks, 0, $minCount);
}

/**
 * Wattpad'den Türkçe HOT/TRENDING kitapları çeker
 * readCount (okuma sayısı) yüksek olanlar önce gelir
 */
function fetchTurkishHot($query, $minCount = 8) {
    $allBooks = [];
    $offset = 0;
    $maxAttempts = 3;
    $limit = max($minCount * 3, 20);
    
    for ($i = 0; $i < $maxAttempts && count($allBooks) < $minCount; $i++) {
        $url = "https://www.wattpad.com/v4/search/stories?query=" . urlencode($query) 
             . "&limit=" . $limit 
             . "&language=23"
             . "&offset=" . $offset
             . "&fields=stories(id,title,cover,description,user(name,username),categories,language(id),readCount,voteCount)"
             . "&mature=0";
        
        $res = fetchWattpad($url);
        if (!isset($res['stories']) || empty($res['stories'])) break;
        
        $turkishOnly = filterTurkishOnly($res['stories']);
        $allBooks = array_merge($allBooks, $turkishOnly);
        
        $offset += $limit;
    }
    
    // ReadCount'a göre azalan sırada sırala (en çok okunan ilk)
    usort($allBooks, function($a, $b) {
        $readA = $a['readCount'] ?? 0;
        $readB = $b['readCount'] ?? 0;
        return $readB - $readA;
    });
    
    return array_slice($allBooks, 0, $minCount);
}

// ==================== DASHBOARD ====================
if ($action === 'dashboard') {
    $latest_stories = fetchTurkishBooks("sevgi", 8);
    
    // Popular: En çok okunan Türkçe kitaplar (readCount'a göre sıralı)
    $popular_stories = fetchTurkishHot("en çok okunan", 10);
    
    // Featured (Öne Çıkan): Türk trend kitapları  
    $featured_stories = fetchTurkishHot("wattpad trend türkçe", 6);
    
    $latest = [];
    foreach ($latest_stories as $wp) {
        $latest[] = transformBook($wp);
    }
    
    $popular = [];
    foreach ($popular_stories as $wp) {
        $popular[] = transformBook($wp);
    }
    
    $featured = [];
    foreach ($featured_stories as $wp) {
        $featured[] = transformBook($wp);
    }
    
    $response = [
        "slider" => [
            ["id" => "wp_1", "title" => "Wattpad Popüler", "image" => "https://olibrary.space/banner.jpg"]
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
        "featured_book" => $featured
    ];
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit;
}

// ==================== ARAMA ====================
if ($action === 'search') {
    $q = $_GET['q'] ?? '';
    if (empty($q)) {
        echo json_encode(["data" => []]);
        exit;
    }
    
    $stories = fetchTurkishBooks($q, 15);
    
    $data = [];
    foreach ($stories as $wp) {
        $data[] = transformBook($wp);
    }
    
    echo json_encode(["data" => $data], JSON_UNESCAPED_UNICODE);
    exit;
}

// ==================== KATEGORİ ====================
if ($action === 'category') {
    $catId = $_GET['cat_id'] ?? '';
    
    $catQueries = [
        "1" => "aşk romantik",
        "4" => "korku gerilim",
        "5" => "fantastik bilim kurgu",
        "9" => "gençlik lise",
        "10" => "roman hikaye"
    ];
    
    $searchTerm = $catQueries[$catId] ?? "türkçe kitap";
    $stories = fetchTurkishBooks($searchTerm, 15);
    
    $data = [];
    foreach ($stories as $wp) {
        $data[] = transformBook($wp);
    }
    
    echo json_encode(["data" => $data], JSON_UNESCAPED_UNICODE);
    exit;
}

// ==================== PDF OKUMA ====================
if ($action === 'read') {
    $id = $_GET['id'] ?? '';
    if (empty($id)) {
        echo json_encode(["error" => "ID belirtilmedi"]);
        exit;
    }
    
    $pdf_file = $cache_dir . '/' . $id . '.pdf';
    $pdf_url = "https://olibrary.space/cache/" . $id . ".pdf";
    
    if (file_exists($pdf_file) && filesize($pdf_file) > 1000) {
        header("Location: " . $pdf_url);
        exit;
    }
    
    // Python betiğini çalıştırarak PDF oluşturuyoruz
    $command = "python3 gen_pdf.py " . escapeshellarg($id) . " " . escapeshellarg($pdf_file) . " 2>&1";
    exec($command, $output_array, $return_var);
    $output = implode("\n", $output_array);
    
    if (file_exists($pdf_file) && filesize($pdf_file) > 1000) {
        header("Location: " . $pdf_url);
        exit;
    } else {
        header('Content-Type: text/plain; charset=utf-8');
        echo "Hata: PDF oluşturulamadı.\nLog çıktısı:\n" . $output;
        exit;
    }
}

echo json_encode(["error" => "Geçersiz işlem"]);
?>
