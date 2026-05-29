<?php
/**
 * OLibrary Portal - Premium Storytel-Style Web Portal & SEO Gateway
 * Hızlı sunucu tarafında işleme (SSR) ve %100 SEO Dostu yapı
 */

error_reporting(0);
ini_set('display_errors', 0);

// Helper function to fetch addon data locally with automatic dynamic caching
function fetchAddonData($addon, $action, $extra = '') {
    $cacheDir = __DIR__ . '/cache';
    if (!is_dir($cacheDir)) {
        @mkdir($cacheDir, 0777, true);
    }
    
    // Unique cache key based on query parameters
    $cacheKey = md5($addon . '_' . $action . '_' . $extra);
    $cacheFile = $cacheDir . '/' . $cacheKey . '.json';
    
    // 5 minutes local cache (300 seconds) - provides instant page rendering
    $nocache = isset($_GET['nocache']) || isset($_GET['clear_cache']);
    if (!$nocache && file_exists($cacheFile) && (time() - filemtime($cacheFile) < 300)) {
        $content = @file_get_contents($cacheFile);
        $data = json_decode($content, true);
        if (is_array($data) && !empty($data)) {
            return $data;
        }
    }
    
    $host = $_SERVER['HTTP_HOST'] ?? 'olibrary.space';
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    
    $bridgeFiles = [
        'tgaddons' => 'tgaddons_bridge.php',
        'booksfer' => 'booksfer_bridge.php',
        'wattpad'  => 'bridge.php'
    ];
    
    $bridge = $bridgeFiles[$addon] ?? 'tgaddons_bridge.php';
    $url = "{$protocol}://{$host}/{$bridge}?action={$action}{$extra}";
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    curl_setopt($ch, CURLOPT_TIMEOUT, 6);
    curl_setopt($ch, CURLOPT_USERAGENT, 'LitrexOfficialApp / 1.0 (OLibrary Bot)');
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'X-OLibrary-Key: Litrex_Secret_Addon_Token_2026_Secure'
    ]);
    
    $response = curl_exec($ch);
    curl_close($ch);
    
    // Fallback: local direct loopback address if loopback is blocked externally
    if (empty($response)) {
        $url = "http://127.0.0.1/{$bridge}?action={$action}{$extra}";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 5);
        curl_setopt($ch, CURLOPT_USERAGENT, 'LitrexOfficialApp / 1.0 (OLibrary Bot)');
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Host: ' . $host,
            'X-OLibrary-Key: Litrex_Secret_Addon_Token_2026_Secure'
        ]);
        $response = curl_exec($ch);
        curl_close($ch);
    }
    
    if (!empty($response)) {
        @file_put_contents($cacheFile, $response);
    }
    
    return json_decode($response, true);
}

// Track and return real dynamic views on top of realistic marketing numbers
function getViewsCount($bookId) {
    $viewsDir = __DIR__ . '/views';
    if (!is_dir($viewsDir)) {
        @mkdir($viewsDir, 0777, true);
    }
    $file = $viewsDir . '/' . md5($bookId) . '.txt';
    
    // Base static realistic view count so the site doesn't show "0 views" for new books
    $hash = abs(crc32((string)$bookId));
    $baseViews = ($hash % 11500) + 1450;
    
    $currentViews = 0;
    if (file_exists($file)) {
        $currentViews = (int)@file_get_contents($file);
    }
    
    return number_format($baseViews + $currentViews);
}

// Increment real dynamic views persistently
function incrementViews($bookId) {
    $viewsDir = __DIR__ . '/views';
    if (!is_dir($viewsDir)) {
        @mkdir($viewsDir, 0777, true);
    }
    $file = $viewsDir . '/' . md5($bookId) . '.txt';
    
    $currentViews = 0;
    if (file_exists($file)) {
        $currentViews = (int)@file_get_contents($file);
    }
    $currentViews++;
    @file_put_contents($file, (string)$currentViews);
}

// Extract current routing state
$addon = $_GET['addon'] ?? 'tgaddons';
if (!in_array($addon, ['tgaddons', 'booksfer', 'wattpad'])) {
    $addon = 'tgaddons';
}

$host = $_SERVER['HTTP_HOST'] ?? 'olibrary.space';
$protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$base_url = "{$protocol}://{$host}";

$bookId = $_GET['book'] ?? '';
$searchQuery = $_GET['q'] ?? '';
$activeBook = null;

// Search query execution
$searchResults = null;
if (!empty($searchQuery)) {
    $searchResults = fetchAddonData($addon, 'search', '&q=' . urlencode($searchQuery));
}

// If a book is selected, pull its metadata for SEO indexing and detail rendering
if (!empty($bookId)) {
    // Search the selected addon directly
    $searchResult = fetchAddonData($addon, 'search', '&q=' . urlencode($bookId));
    if (!empty($searchResult['data'])) {
        foreach ($searchResult['data'] as $b) {
            if ($b['id'] == $bookId) {
                $activeBook = $b;
                break;
            }
        }
    }
    
    // Fallback search in dashboard if search did not return it
    if (!$activeBook) {
        $dash = fetchAddonData($addon, 'dashboard');
        $all = array_merge($dash['latest_book'] ?? [], $dash['popular_book'] ?? [], $dash['featured_book'] ?? []);
        foreach ($all as $b) {
            if ($b['id'] == $bookId) {
                $activeBook = $b;
                break;
            }
        }
    }

    // Dynamic views auto-increment trigger
    if ($activeBook) {
        incrementViews($activeBook['id']);
    }
}

// Pull active addon dashboard catalog
$dashboard = fetchAddonData($addon, 'dashboard');

// SEO tags variables
$seoTitle = "OLibrary - Açık Kaynaklı Eklenti Havuzu";
$seoDesc = "OLibrary, bağımsız ve açık protokol standartlarıyla internetteki halka açık e-kitap arşivlerini tarayan akıllı eklenti dizinidir.";
$seoImage = $base_url . "/banner.jpg";
$seoUrl = $base_url . $_SERVER['REQUEST_URI'];
$seoKeywords = "kitap oku, pdf indir, epub indir, e-kitap indir, olibrary, booksfer, wattpad türkçe, ücretsiz kitap pdf";

if ($activeBook) {
    // Dynamic premium title structure for maximum Google click-through rate
    $seoTitle = htmlspecialchars($activeBook['name']) . " | PDF İNDİR ve Oku - Yazar: " . htmlspecialchars($activeBook['author_name']) . " | OLibrary";
    
    // Dynamic high-relevance search description snippet
    $seoDesc = htmlspecialchars($activeBook['name']) . " kitabı için ücretsiz PDF indir veya çevrimiçi oku. Yazar: " . htmlspecialchars($activeBook['author_name']) . ". Kitap özeti ve detayı: " . htmlspecialchars(mb_substr(strip_tags($activeBook['description']), 0, 140) . '...');
    
    // Dynamic meta keywords targeting long-tail queries
    $seoKeywords = htmlspecialchars($activeBook['name']) . " pdf indir, " . htmlspecialchars($activeBook['name']) . " oku, " . htmlspecialchars($activeBook['name']) . " yazar " . htmlspecialchars($activeBook['author_name']) . ", " . htmlspecialchars($activeBook['category_name']) . " pdf, " . $seoKeywords;
    
    if (!empty($activeBook['logo'])) {
        $seoImage = $activeBook['logo'];
    }
}

$addonManifests = [
    'tgaddons' => 'tgaddons.json',
    'booksfer' => 'booksfer_addon.json',
    'wattpad'  => 'addon.json'
];
$activeManifest = $addonManifests[$addon] ?? 'tgaddons.json';
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    
    <!-- 100% Google SEO Dynamic Headers -->
    <title><?php echo $seoTitle; ?></title>
    <meta name="description" content="<?php echo $seoDesc; ?>">
    <meta name="keywords" content="<?php echo $seoKeywords; ?>">
    <link rel="canonical" href="<?php echo $seoUrl; ?>">
    
    <!-- Dynamic Schema.org JSON-LD Structured Data for Google Rich Snippets -->
    <?php if ($activeBook): ?>
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "Book",
      "name": "<?php echo addslashes($activeBook['name']); ?>",
      "image": "<?php echo addslashes($seoImage); ?>",
      "author": {
        "@type": "Person",
        "name": "<?php echo addslashes($activeBook['author_name']); ?>"
      },
      "genre": "<?php echo addslashes($activeBook['category_name']); ?>",
      "description": "<?php echo addslashes(mb_substr(strip_tags($activeBook['description']), 0, 250)); ?>",
      "workExample": {
        "@type": "Book",
        "bookFormat": "https://schema.org/EBook",
        "potentialAction": {
          "@type": "DownloadAction",
          "target": "<?php echo addslashes($seoUrl); ?>"
        }
      }
    }
    </script>
    <?php endif; ?>

    <!-- OpenGraph (Facebook, Telegram, WhatsApp sharing headers) -->
    <meta property="og:type" content="book">
    <meta property="og:title" content="<?php echo $seoTitle; ?>">
    <meta property="og:description" content="<?php echo $seoDesc; ?>">
    <meta property="og:image" content="<?php echo $seoImage; ?>">
    <meta property="og:url" content="<?php echo $seoUrl; ?>">
    <meta property="og:site_name" content="OLibrary">
    
    <!-- Twitter Cards -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="<?php echo $seoTitle; ?>">
    <meta name="twitter:description" content="<?php echo $seoDesc; ?>">
    <meta name="twitter:image" content="<?php echo $seoImage; ?>">

    <!-- Premium Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                        outfit: ['Outfit', 'sans-serif'],
                    }
                }
            }
        }
    </script>
    
    <style>
        body {
            background: radial-gradient(circle at 50% 0%, #130f2b 0%, #05060b 100%);
            color: #f1f5f9;
            min-height: 100vh;
            overflow-x: hidden;
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.02);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 20px;
        }
        .glass-header {
            background: rgba(5, 6, 11, 0.75);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
        }
        .gradient-text {
            background: linear-gradient(135deg, #a78bfa 0%, #6366f1 50%, #38bdf8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .btn-premium {
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 20px rgba(99, 102, 241, 0.3);
        }
        .btn-premium:hover {
            box-shadow: 0 6px 24px rgba(139, 92, 246, 0.5);
            transform: translateY(-2px);
        }
        .scrollbar-hide::-webkit-scrollbar {
            display: none;
        }
        .scrollbar-hide {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
        .ambient-glow {
            filter: blur(120px);
            opacity: 0.15;
            pointer-events: none;
        }
        /* Mobile Touch Optimizations */
        @media (max-width: 640px) {
            body {
                background: #05060b;
            }
            .glass-card {
                border-radius: 16px;
            }
        }
    </style>
</head>
<body class="font-sans antialiased select-none">

    <!-- Ambient background glows -->
    <div class="absolute top-0 left-1/4 w-[400px] h-[400px] bg-purple-600 rounded-full ambient-glow"></div>
    <div class="absolute top-[300px] right-1/4 w-[400px] h-[400px] bg-indigo-600/full ambient-glow"></div>

    <!-- Sticky Header -->
    <header class="glass-header w-full sticky top-0 z-40 transition-all duration-300">
        <div class="max-w-6xl mx-auto px-4 py-3 flex justify-between items-center gap-4">
            <a href="index.php" class="text-xl md:text-2xl font-outfit font-extrabold tracking-tight text-white flex items-center gap-1.5 flex-shrink-0">
                <span class="w-7 h-7 rounded-lg bg-indigo-600 flex items-center justify-center text-xs font-bold shadow-lg shadow-indigo-600/30">O</span>
                <span>Library</span>
            </a>
            
            <!-- Real-Time Search Bar -->
            <form action="index.php" method="GET" class="flex-grow max-w-md relative hidden sm:block">
                <input type="hidden" name="addon" value="<?php echo $addon; ?>">
                <input type="text" name="q" placeholder="Kitap veya yazar ara..." value="<?php echo htmlspecialchars($searchQuery); ?>" 
                       class="w-full bg-white/5 focus:bg-white/10 border border-white/10 focus:border-indigo-500/50 rounded-xl px-4 py-1.5 text-xs text-white focus:outline-none transition-all duration-300">
                <button type="submit" class="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400 hover:text-white transition">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                </button>
            </form>

            <div class="flex items-center gap-2 md:gap-4 flex-shrink-0">
                <button onclick="triggerAppAlert()" class="px-3.5 py-1.5 rounded-lg bg-indigo-600/20 hover:bg-indigo-600 border border-indigo-500/20 text-xs font-bold text-indigo-300 hover:text-white transition flex items-center gap-1.5">
                    🚀 Uygulamaya Ekle
                </button>
            </div>
        </div>
        
        <!-- Mobile Search Bar -->
        <div class="px-4 pb-3 pt-1 block sm:hidden">
            <form action="index.php" method="GET" class="w-full relative">
                <input type="hidden" name="addon" value="<?php echo $addon; ?>">
                <input type="text" name="q" placeholder="Kitap veya yazar ara..." value="<?php echo htmlspecialchars($searchQuery); ?>" 
                       class="w-full bg-white/5 focus:bg-white/10 border border-white/10 focus:border-indigo-500/50 rounded-xl px-4 py-2 text-xs text-white focus:outline-none transition-all duration-300">
                <button type="submit" class="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                </button>
            </form>
        </div>
    </header>

    <main class="max-w-6xl mx-auto px-4 py-4 md:py-8">
        
        <?php if ($activeBook): ?>
            <!-- ==================== DEDICATED BOOK DETAIL PAGE (Storytel Style) ==================== -->
            <div class="mb-4">
                <a href="index.php?addon=<?php echo $addon; ?>" class="inline-flex items-center gap-2 text-[10px] font-semibold text-slate-400 hover:text-white transition uppercase tracking-wider">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
                    Kataloğa Geri Dön
                </a>
            </div>

            <!-- SEO Rich Header (Hidden for visuals, crawled by bots) -->
            <h2 class="sr-only"><?php echo htmlspecialchars($activeBook['name']); ?> PDF İndir - Kitabı Ücretsiz Oku</h2>

            <div class="glass-card p-4 md:p-12 flex flex-col md:flex-row gap-6 md:gap-12 items-center md:items-start relative overflow-hidden">
                <!-- Cover Glow Shadow -->
                <div class="absolute -top-12 -left-12 w-64 h-64 bg-indigo-500/10 rounded-full blur-3xl"></div>
                
                <!-- Book Cover Container -->
                <div class="w-40 sm:w-48 md:w-64 flex-shrink-0 relative group">
                    <div class="absolute inset-0 bg-indigo-600/30 rounded-2xl blur-xl opacity-50 group-hover:opacity-80 transition duration-500"></div>
                    <img src="<?php echo !empty($activeBook['logo']) ? $activeBook['logo'] : ($base_url . '/banner.jpg'); ?>" 
                         alt="<?php echo htmlspecialchars($activeBook['name']); ?> PDF Oku" 
                         class="w-full rounded-2xl shadow-2xl relative z-10 border border-white/10 object-cover aspect-[2/3] transition-transform duration-500 group-hover:scale-[1.02]"
                         onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400';">
                </div>

                <!-- Book Information Details -->
                <div class="flex-grow text-center md:text-left relative z-10 w-full">
                    <span class="inline-block px-3 py-1 rounded-full bg-indigo-500/10 border border-indigo-500/20 text-xs font-semibold text-indigo-300 uppercase tracking-wide mb-3">
                        <?php echo htmlspecialchars($activeBook['category_name']); ?>
                    </span>

                    <h1 class="text-2xl md:text-5xl font-outfit font-extrabold text-white leading-tight mb-2">
                        <?php echo htmlspecialchars($activeBook['name']); ?>
                    </h1>

                    <p class="text-sm md:text-lg text-indigo-200/80 font-medium mb-4">
                        ✍️ Yazar: <span class="text-white font-semibold"><?php echo htmlspecialchars($activeBook['author_name']); ?></span>
                    </p>

                    <!-- Viewer Counter Badges (Replacing ratings) -->
                    <div class="flex flex-wrap items-center justify-center md:justify-start gap-4 text-xs text-slate-400 mb-6 border-y border-white/5 py-3">
                        <div class="flex items-center gap-1.5 text-indigo-300 font-semibold">
                            👁️ <?php echo getViewsCount($activeBook['id']); ?> bakış / okunma
                        </div>
                        <div class="w-1.5 h-1.5 bg-slate-600 rounded-full"></div>
                        <div>📖 Eklenti Köprüsü</div>
                        <div class="w-1.5 h-1.5 bg-slate-600 rounded-full"></div>
                        <div class="text-green-400 font-bold uppercase tracking-wider text-[10px]">Açık İndeks</div>
                    </div>

                    <!-- Book Description -->
                    <div class="mb-6 text-left">
                        <h3 class="text-[10px] font-semibold text-slate-400 uppercase tracking-widest mb-2">Kitap Açıklaması</h3>
                        <p class="text-slate-300 leading-relaxed text-xs md:text-sm max-w-2xl">
                            <?php echo nl2br(htmlspecialchars($activeBook['description'])); ?>
                        </p>
                    </div>

                    <!-- CTA Read/Download Buttons -->
                    <div class="flex flex-col sm:flex-row gap-3">
                        <button onclick="triggerAppAlert()" class="btn-premium px-6 py-3 rounded-xl font-bold text-xs tracking-wide text-white transition flex items-center justify-center gap-2">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path></svg>
                            KİTABI OKU (UYGULAMADA AÇ)
                        </button>
                        <button onclick="triggerAppAlert()" class="px-6 py-3 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 font-bold text-xs tracking-wide text-white transition flex items-center justify-center gap-2">
                            <svg class="w-4 h-4 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path></svg>
                            PDF İNDİR / YÜKLE
                        </button>
                    </div>
                </div>
            </div>

            <!-- More books from this addon -->
            <div class="mt-12">
                <h3 class="text-lg font-outfit font-extrabold text-white mb-4 flex items-center gap-2">
                    <span class="w-1 h-5 bg-indigo-500 rounded-full"></span>
                    Benzer Önerilen Kitaplar
                </h3>
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">
                    <?php
                    $suggested = array_slice($dashboard['popular_book'] ?? [], 0, 5);
                    foreach ($suggested as $b):
                    ?>
                        <a href="index.php?addon=<?php echo $addon; ?>&book=<?php echo $b['id']; ?>" class="bg-white/[0.01] border border-white/5 rounded-xl p-2.5 flex flex-col group transition-all duration-300 hover:bg-white/[0.03] hover:border-white/10 relative">
                            <!-- Hidden SEO text -->
                            <span class="sr-only"><?php echo htmlspecialchars($b['name']); ?> PDF İndir</span>
                            <div class="relative rounded-lg overflow-hidden mb-2 aspect-[2/3] w-full bg-slate-800 shadow-md">
                                <img src="<?php echo $b['logo']; ?>" alt="<?php echo htmlspecialchars($b['name']); ?>" class="w-full h-full object-cover transition duration-500 group-hover:scale-105" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=200';">
                            </div>
                            <h4 class="text-xs font-bold text-white truncate group-hover:text-indigo-400 transition mb-0.5"><?php echo htmlspecialchars($b['name']); ?></h4>
                            <p class="text-[10px] text-slate-400 truncate"><?php echo htmlspecialchars($b['author_name']); ?></p>
                            <div class="flex items-center justify-between mt-1 text-[9px] text-indigo-300">
                                <span>👁️ <?php echo getViewsCount($b['id']); ?></span>
                            </div>
                        </a>
                    <?php endforeach; ?>
                </div>
            </div>

        <?php elseif (!empty($searchQuery)): ?>
            <!-- ==================== SEARCH RESULTS VIEW ==================== -->
            <section class="mb-12">
                <div class="mb-6 flex justify-between items-center">
                    <div>
                        <h2 class="text-xl md:text-2xl font-outfit font-extrabold text-white">Arama Sonuçları</h2>
                        <p class="text-xs text-slate-400">"<?php echo htmlspecialchars($searchQuery); ?>" için arama sonuçları listeleniyor.</p>
                    </div>
                    <a href="index.php?addon=<?php echo $addon; ?>" class="text-xs text-indigo-400 hover:underline">Aramayı Temizle</a>
                </div>

                <?php if (!empty($searchResults['data'])): ?>
                    <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">
                        <?php foreach ($searchResults['data'] as $b): ?>
                            <a href="index.php?addon=<?php echo $addon; ?>&book=<?php echo $b['id']; ?>" class="glass-card p-3 flex flex-col justify-between group transition-all duration-300 hover:border-white/10 hover:bg-white/[0.03]">
                                <span class="sr-only"><?php echo htmlspecialchars($b['name']); ?> PDF İndir</span>
                                <div class="rounded-xl overflow-hidden aspect-[2/3] w-full bg-slate-800 shadow-lg mb-2 relative">
                                    <img src="<?php echo $b['logo']; ?>" alt="<?php echo htmlspecialchars($b['name']); ?>" class="w-full h-full object-cover transition duration-500 group-hover:scale-105" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=200';">
                                </div>
                                <div>
                                    <h4 class="text-xs font-bold text-white line-clamp-1 group-hover:text-indigo-300 transition"><?php echo htmlspecialchars($b['name']); ?></h4>
                                    <p class="text-[10px] text-slate-400 truncate mt-0.5"><?php echo htmlspecialchars($b['author_name']); ?></p>
                                </div>
                                <div class="flex items-center justify-between mt-2 text-[9px] text-indigo-300">
                                    <span>👁️ <?php echo getViewsCount($b['id']); ?> okunma</span>
                                </div>
                            </a>
                        <?php endforeach; ?>
                    </div>
                <?php else: ?>
                    <div class="glass-card p-12 text-center text-slate-400 text-sm">
                        ⚠️ Aradığınız kitap bu eklentide bulunamadı. Lütfen diğer eklentileri seçip tekrar arayın.
                    </div>
                <?php endif; ?>
            </section>

        <?php else: ?>
            <!-- ==================== MAIN CATALOG PAGE (Storytel Style) ==================== -->
            
            <!-- Hero Promo Banner -->
            <section class="glass-card p-6 md:p-12 mb-8 relative overflow-hidden flex flex-col md:flex-row items-center justify-between gap-6">
                <div class="absolute -top-24 -right-24 w-[300px] h-[300px] bg-indigo-600/10 rounded-full blur-3xl"></div>
                <div class="relative z-10 text-center md:text-left max-w-xl">
                    <div class="inline-block px-2.5 py-1 rounded-full bg-indigo-500/10 border border-indigo-500/20 text-[10px] font-semibold text-indigo-300 uppercase tracking-wider mb-3">
                        ✨ Açık Kaynak Kitap Havuzu
                    </div>
                    <h1 class="text-3xl md:text-5xl font-outfit font-extrabold text-white tracking-tight mb-3 leading-tight">
                        Evrensel Kitap <br> <span class="gradient-text">Eklenti Portalı</span>
                    </h1>
                    <p class="text-slate-400 text-xs md:text-sm leading-relaxed">
                        OLibrary, tamamen merkeziyetsiz bir eklenti indeksleyicisidir. İstediğiniz kütüphane eklentisini uyumlu okuyucu istemcinize ekleyerek binlerce kitaba telif hakkı korumalı olarak anında ulaşabilirsiniz.
                    </p>
                </div>
                <div class="w-36 h-36 md:w-44 md:h-44 relative z-10 flex-shrink-0 flex items-center justify-center bg-indigo-500/5 rounded-full border border-white/5 shadow-2xl">
                    <div class="absolute inset-2 rounded-full border border-dashed border-indigo-500/20 animate-spin" style="animation-duration: 30s;"></div>
                    <div class="text-center">
                        <span class="text-2xl md:text-3xl font-outfit font-black text-indigo-400">10,000+</span>
                        <span class="block text-[9px] text-slate-400 uppercase tracking-widest mt-0.5">Eşleşen Kitap</span>
                    </div>
                </div>
            </section>

            <!-- Addon Platform Tabs (Storytel Selector) -->
            <section class="mb-8">
                <div class="flex flex-col justify-between items-start gap-1 mb-4">
                    <h2 class="text-xl font-outfit font-extrabold text-white tracking-tight">Kütüphane Eklenti Sunucuları</h2>
                    <p class="text-xs text-slate-400">Hangi eklenti arşivindeki kitapları görüntülemek istediğinizi seçin.</p>
                </div>
                
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <!-- Tab Button 1: Telegram Kitaplığı -->
                    <div onclick="window.location.href='index.php?addon=tgaddons'" class="glass-card p-4 flex items-center justify-between gap-3 transition-all duration-300 hover:border-indigo-500/30 group cursor-pointer <?php echo $addon === 'tgaddons' ? 'ring-1.5 ring-indigo-500/50 bg-indigo-500/[0.02]' : ''; ?>">
                        <div class="flex items-start gap-3 min-w-0">
                            <div class="w-10 h-10 rounded-xl bg-blue-500/10 text-blue-400 flex items-center justify-center flex-shrink-0 group-hover:scale-105 transition-transform duration-300">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path></svg>
                            </div>
                            <div class="min-w-0">
                                <h3 class="font-outfit font-bold text-white flex items-center gap-1.5 text-sm">
                                    Telegram Kitaplığı
                                    <span class="px-1 py-0.5 rounded bg-blue-500/20 text-[8px] text-blue-300 uppercase font-extrabold tracking-wider">Arşiv</span>
                                </h3>
                                <p class="text-[10px] text-slate-400 leading-normal mt-1 truncate">Telegram kanallarındaki zengin PDF kütüphanesi.</p>
                            </div>
                        </div>
                        <button onclick="event.stopPropagation(); triggerAddonWithManifest('tgaddons.json')" class="px-3 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-[10px] font-bold text-white transition flex-shrink-0 shadow-lg shadow-indigo-600/25">
                            Ekle
                        </button>
                    </div>

                    <!-- Tab Button 2: Booksfer -->
                    <div onclick="window.location.href='index.php?addon=booksfer'" class="glass-card p-4 flex items-center justify-between gap-3 transition-all duration-300 hover:border-purple-500/30 group cursor-pointer <?php echo $addon === 'booksfer' ? 'ring-1.5 ring-purple-500/50 bg-purple-500/[0.02]' : ''; ?>">
                        <div class="flex items-start gap-3 min-w-0">
                            <div class="w-10 h-10 rounded-xl bg-purple-500/10 text-purple-400 flex items-center justify-center flex-shrink-0 group-hover:scale-105 transition-transform duration-300">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path></svg>
                            </div>
                            <div class="min-w-0">
                                <h3 class="font-outfit font-bold text-white flex items-center gap-1.5 text-sm">
                                    Booksfer Eklentisi
                                    <span class="px-1 py-0.5 rounded bg-purple-500/20 text-[8px] text-purple-300 uppercase font-extrabold tracking-wider">Premium</span>
                                </h3>
                                <p class="text-[10px] text-slate-400 leading-normal mt-1 truncate">Zengin kitap veritabanı sunan resmi API eklentisi.</p>
                            </div>
                        </div>
                        <button onclick="event.stopPropagation(); triggerAddonWithManifest('booksfer_addon.json')" class="px-3 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-[10px] font-bold text-white transition flex-shrink-0 shadow-lg shadow-indigo-600/25">
                            Ekle
                        </button>
                    </div>

                    <!-- Tab Button 3: Wattpad -->
                    <div onclick="window.location.href='index.php?addon=wattpad'" class="glass-card p-4 flex items-center justify-between gap-3 transition-all duration-300 hover:border-pink-500/30 group cursor-pointer <?php echo $addon === 'wattpad' ? 'ring-1.5 ring-pink-500/50 bg-pink-500/[0.02]' : ''; ?>">
                        <div class="flex items-start gap-3 min-w-0">
                            <div class="w-10 h-10 rounded-xl bg-pink-500/10 text-pink-400 flex items-center justify-center flex-shrink-0 group-hover:scale-105 transition-transform duration-300">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
                            </div>
                            <div class="min-w-0">
                                <h3 class="font-outfit font-bold text-white flex items-center gap-1.5 text-sm">
                                    Wattpad Köprüsü
                                    <span class="px-1 py-0.5 rounded bg-pink-500/20 text-[8px] text-pink-300 uppercase font-extrabold tracking-wider">UGC</span>
                                </h3>
                                <p class="text-[10px] text-slate-400 leading-normal mt-1 truncate">Halka açık Türkçe kullanıcı içeriklerini indeksleyen köprü.</p>
                            </div>
                        </div>
                        <button onclick="event.stopPropagation(); triggerAddonWithManifest('addon.json')" class="px-3 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-[10px] font-bold text-white transition flex-shrink-0 shadow-lg shadow-indigo-600/25">
                            Ekle
                        </button>
                    </div>
                </div>
            </section>

            <!-- 1. FEATURED BOOKS CAROUSEL -->
            <?php if (!empty($dashboard['featured_book'])): ?>
            <section class="mb-10">
                <h3 class="text-lg md:text-2xl font-outfit font-extrabold text-white mb-4 flex items-center gap-2">
                    <span class="w-1 h-5 bg-indigo-500 rounded-full"></span>
                    Öne Çıkan Arşiv Kitapları
                </h3>
                <div class="flex gap-4 overflow-x-auto pb-3 scrollbar-hide">
                    <?php foreach ($dashboard['featured_book'] as $b): ?>
                        <a href="index.php?addon=<?php echo $addon; ?>&book=<?php echo $b['id']; ?>" 
                           class="w-36 sm:w-44 flex-shrink-0 glass-card p-3 flex flex-col justify-between group transition-all duration-300 hover:border-white/10 hover:bg-white/[0.03] relative">
                            <span class="sr-only"><?php echo htmlspecialchars($b['name']); ?> PDF İndir</span>
                            <div class="rounded-lg overflow-hidden aspect-[2/3] w-full bg-slate-800 shadow-md mb-2 relative">
                                <img src="<?php echo $b['logo']; ?>" alt="<?php echo htmlspecialchars($b['name']); ?>" class="w-full h-full object-cover transition duration-500 group-hover:scale-105" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=200';">
                            </div>
                            <div>
                                <h4 class="text-xs font-bold text-white line-clamp-1 group-hover:text-indigo-300 transition"><?php echo htmlspecialchars($b['name']); ?></h4>
                                <p class="text-[10px] text-slate-400 truncate mt-0.5"><?php echo htmlspecialchars($b['author_name']); ?></p>
                            </div>
                            <div class="flex items-center justify-between mt-2 text-[9px] text-indigo-300">
                                <span>👁️ <?php echo getViewsCount($b['id']); ?></span>
                            </div>
                        </a>
                    <?php endforeach; ?>
                </div>
            </section>
            <?php endif; ?>

            <!-- 2. POPULAR BOOKS GRID -->
            <?php if (!empty($dashboard['popular_book'])): ?>
            <section class="mb-10">
                <h3 class="text-lg md:text-2xl font-outfit font-extrabold text-white mb-4 flex items-center gap-2">
                    <span class="w-1 h-5 bg-purple-500 rounded-full"></span>
                    Popüler Okuma Listeleri
                </h3>
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">
                    <?php foreach ($dashboard['popular_book'] as $b): ?>
                        <a href="index.php?addon=<?php echo $addon; ?>&book=<?php echo $b['id']; ?>" 
                           class="glass-card p-3 flex flex-col justify-between group transition-all duration-300 hover:border-white/10 hover:bg-white/[0.03] relative">
                            <span class="sr-only"><?php echo htmlspecialchars($b['name']); ?> PDF İndir</span>
                            <div class="rounded-lg overflow-hidden aspect-[2/3] w-full bg-slate-800 shadow-md mb-2 relative">
                                <img src="<?php echo $b['logo']; ?>" alt="<?php echo htmlspecialchars($b['name']); ?>" class="w-full h-full object-cover transition duration-500 group-hover:scale-105" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=200';">
                            </div>
                            <div>
                                <h4 class="text-xs font-bold text-white line-clamp-1 group-hover:text-purple-300 transition"><?php echo htmlspecialchars($b['name']); ?></h4>
                                <p class="text-[10px] text-slate-400 truncate mt-0.5"><?php echo htmlspecialchars($b['author_name']); ?></p>
                            </div>
                            <div class="flex items-center justify-between mt-2 text-[9px] text-indigo-300">
                                <span>👁️ <?php echo getViewsCount($b['id']); ?></span>
                            </div>
                        </a>
                    <?php endforeach; ?>
                </div>
            </section>
            <?php endif; ?>

            <!-- 3. LATEST BOOKS LIST -->
            <?php if (!empty($dashboard['latest_book'])): ?>
            <section class="mb-10">
                <h3 class="text-lg md:text-2xl font-outfit font-extrabold text-white mb-4 flex items-center gap-2">
                    <span class="w-1 h-5 bg-cyan-500 rounded-full"></span>
                    Son Eklenen Harici Eserler
                </h3>
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">
                    <?php foreach ($dashboard['latest_book'] as $b): ?>
                        <a href="index.php?addon=<?php echo $addon; ?>&book=<?php echo $b['id']; ?>" 
                           class="glass-card p-3 flex flex-col justify-between group transition-all duration-300 hover:border-white/10 hover:bg-white/[0.03] relative">
                            <span class="sr-only"><?php echo htmlspecialchars($b['name']); ?> PDF İndir</span>
                            <div class="rounded-lg overflow-hidden aspect-[2/3] w-full bg-slate-800 shadow-md mb-2 relative">
                                <img src="<?php echo $b['logo']; ?>" alt="<?php echo htmlspecialchars($b['name']); ?>" class="w-full h-full object-cover transition duration-500 group-hover:scale-105" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=200';">
                            </div>
                            <div>
                                <h4 class="text-xs font-bold text-white line-clamp-1 group-hover:text-cyan-300 transition"><?php echo htmlspecialchars($b['name']); ?></h4>
                                <p class="text-[10px] text-slate-400 truncate mt-0.5"><?php echo htmlspecialchars($b['author_name']); ?></p>
                            </div>
                            <div class="flex items-center justify-between mt-2 text-[9px] text-indigo-300">
                                <span>👁️ <?php echo getViewsCount($b['id']); ?> okuma</span>
                            </div>
                        </a>
                    <?php endforeach; ?>
                </div>
            </section>
            <?php endif; ?>

        <?php endif; ?>

        <!-- ==================== PROTOCOL DETAILS / DEVELOPER INFO ==================== -->
        <section id="developers" class="mt-16 border-t border-white/5 pt-12">
            <div class="max-w-3xl mx-auto">
                <h2 class="text-2xl font-outfit font-extrabold text-white text-center mb-2">Medya Eklenti Protokolü</h2>
                <p class="text-slate-400 text-center text-xs mb-8 max-w-xl mx-auto">OLibrary, e-kitap sunumlarını tamamen bağımsız eklentilere devreden açık kaynaklı standarttır.</p>
                
                <div class="glass-card p-4 md:p-8">
                    <h3 class="text-xs font-bold text-indigo-400 uppercase tracking-widest mb-2">Uygulamada Açma Yöntemi</h3>
                    <p class="text-slate-300 text-xs leading-relaxed mb-4">
                        Uyumlu mobil okuyucu uygulamanız kuruluyken, aşağıdaki eklenti bağlantısını kopyalayıp uygulamaya yapıştırabilir veya doğrudan yükleyebilirsiniz.
                    </p>
                    
                    <div class="bg-black/40 rounded-xl p-3 border border-white/5 mb-4 flex flex-col md:flex-row justify-between items-center gap-3">
                        <code class="text-green-400 font-mono text-[10px] truncate w-full md:w-auto" id="manifest-uri-code">olib://addon?url=https://olibrary.space/<?php echo $activeManifest; ?></code>
                        <button onclick="copyToClipboard('manifest-uri-code')" class="px-3 py-1.5 rounded-lg bg-white/5 hover:bg-white/10 text-white border border-white/10 text-[10px] font-semibold flex items-center gap-1.5 flex-shrink-0 transition">
                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"></path></svg>
                            Bağlantıyı Kopyala
                        </button>
                    </div>

                    <div class="p-3 bg-indigo-500/10 border border-indigo-500/20 rounded-xl text-[10px] leading-relaxed text-indigo-300">
                        ✦ Bu eklenti sunucusu (<code><?php echo $activeManifest; ?></code>) açık internetteki halka açık kaynakları derlemektedir. İndirilecek PDF'ler kullanıcının kendi sorumluluğundadır.
                    </div>
                </div>
            </div>
        </section>

    </main>

    <!-- Footer -->
    <footer class="max-w-6xl mx-auto px-4 py-8 mt-12 border-t border-white/5 text-center flex flex-col md:flex-row items-center justify-between gap-4 text-xs text-slate-500">
        <p>© 2026 OLibrary Project. Açık Kitap Dizini.</p>
        <div class="flex gap-4">
            <a href="#" class="hover:text-white transition">Kullanım Şartları</a>
            <a href="#" class="hover:text-white transition">Gizlilik Politikası</a>
            <a href="#" class="hover:text-white transition">Telif Hakkı</a>
        </div>
    </footer>

    <!-- ==================== PREMIUM CLIENT APP REQUIRED MODAL ==================== -->
    <div id="app-modal" class="fixed inset-0 bg-slate-950/80 backdrop-blur-xl z-50 flex items-center justify-center opacity-0 pointer-events-none transition-all duration-300 p-4">
        <div class="bg-slate-900/90 border border-white/10 rounded-3xl w-full max-w-md p-6 transform scale-95 transition-all duration-300 shadow-2xl relative overflow-hidden">
            <div class="absolute -top-16 -right-16 w-36 h-36 bg-indigo-600/20 rounded-full blur-2xl"></div>
            
            <button onclick="closeAppModal()" class="absolute top-4 right-4 text-slate-400 hover:text-white p-1.5 rounded-lg hover:bg-white/10 transition">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
            </button>

            <div class="text-center">
                <!-- App Icon Placeholder -->
                <div class="w-14 h-14 rounded-2xl bg-indigo-600 flex items-center justify-center text-white text-2xl font-black shadow-lg shadow-indigo-600/30 mx-auto mb-4">
                    O
                </div>
                
                <h3 class="text-xl font-outfit font-extrabold text-white mb-2">Uygulama Gereklidir</h3>
                
                <p class="text-slate-400 text-xs leading-relaxed mb-6">
                    Bu eklentideki kitapları telif hakkı uyumlu, şifreli ve güvenli bir şekilde okumak için uyumlu bir okuyucu uygulaması yüklemeniz gerekmektedir.
                </p>

                <!-- Deep Link CTA -->
                <a id="modal-deep-link-btn" href="olib://addon?url=<?php echo $base_url; ?>/<?php echo $activeManifest; ?>" class="btn-premium w-full py-3 rounded-xl font-bold text-xs tracking-wide text-white transition flex items-center justify-center gap-2 mb-4">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"></path></svg>
                    EKLENTİYİ UYGULAMAYA EKLE
                </a>
            </div>
        </div>
    </div>

    <!-- Toast Notification -->
    <div id="toast" class="fixed bottom-10 left-1/2 transform -translate-x-1/2 bg-slate-800 text-white px-6 py-3 rounded-full shadow-2xl border border-white/10 opacity-0 transition-opacity duration-300 pointer-events-none z-50">
        Bağlantı kopyalandı!
    </div>

    <script>
        function copyToClipboard(id) {
            const urlText = document.getElementById(id).innerText;
            navigator.clipboard.writeText(urlText).then(() => {
                showToast("Bağlantı başarıyla kopyalandı!");
            });
        }

        function copyManifestUrl() {
            const url = "<?php echo $base_url; ?>/<?php echo $activeManifest; ?>";
            navigator.clipboard.writeText(url).then(() => {
                showToast("Eklenti bağlantısı kopyalandı!");
            });
        }

        function showToast(message) {
            const toast = document.getElementById('toast');
            toast.innerText = message;
            toast.classList.remove('opacity-0');
            setTimeout(() => {
                toast.classList.add('opacity-0');
            }, 2500);
        }

        function triggerAppAlert() {
            const modal = document.getElementById('app-modal');
            const content = modal.firstElementChild;
            modal.classList.remove('opacity-0', 'pointer-events-none');
            content.classList.remove('scale-95');
        }

        function triggerAddonWithManifest(manifest) {
            // Update deep link URL dynamically for the clicked manifest
            const deepLinkBtn = document.getElementById('modal-deep-link-btn');
            if (deepLinkBtn) {
                deepLinkBtn.href = `olib://addon?url=<?php echo $base_url; ?>/${manifest}`;
            }
            const manifestCode = document.getElementById('manifest-uri-code');
            if (manifestCode) {
                manifestCode.innerText = `olib://addon?url=<?php echo $base_url; ?>/${manifest}`;
            }
            triggerAppAlert();
        }

        function closeAppModal() {
            const modal = document.getElementById('app-modal');
            const content = modal.firstElementChild;
            modal.classList.add('opacity-0', 'pointer-events-none');
            content.classList.add('scale-95');
        }
    </script>
</body>
</html>
