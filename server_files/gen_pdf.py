import sys
import os
import requests
import html
import re
import concurrent.futures
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Image
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY

# 1. Arqumentləri oxu
if len(sys.argv) < 3:
    print("Kullanım: python3 gen_pdf.py <story_id> <output_path>")
    sys.exit(1)

story_id = sys.argv[1]
output_path = sys.argv[2]

# 2. Azərbaycan hərflərini dəstəkləyən şrifti (Roboto) yüklə
font_path = os.path.dirname(os.path.abspath(__file__)) + "/Roboto-Regular.ttf"
if not os.path.exists(font_path):
    print("Yazı tipi bulunamadı. İndiriliyor...")
    try:
        url = "https://github.com/googlefonts/roboto/raw/main/src/hinted/Roboto-Regular.ttf"
        r = requests.get(url, timeout=10)
        with open(font_path, "wb") as f:
            f.write(r.content)
        print("Yazı tipi başarıyla indirildi.")
    except Exception as e:
        print(f"Yazı tipi indirilirken hata oluştu: {e}")
        # Hata olursa varsayılan fonta geçer, bazı Türkçe harfler (ğ,ş) bozulabilir.

# Şrifti ReportLab-da qeydiyyatdan keçir
try:
    pdfmetrics.registerFont(TTFont("Roboto", font_path))
    FONT_NAME = "Roboto"
except Exception as e:
    print(f"Yazı tipi kayıt hatası: {e}")
    FONT_NAME = "Helvetica"

# 3. Wattpad Story Metadatalarını çək
print(f"Wattpad hikaye verileri çekiliyor (ID: {story_id})...")
headers = {
    "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
}
try:
    story_url = f"https://www.wattpad.com/api/v3/stories/{story_id}"
    res = requests.get(story_url, headers=headers, timeout=12)
    if res.status_code != 200:
        print(f"Hata: Wattpad API {res.status_code} yanıtı döndürdü.")
        sys.exit(1)
    
    story_data = res.json()
except Exception as e:
    print(f"API bağlantı hatası: {e}")
    sys.exit(1)

title = story_data.get('title', 'Başlıksız Hikaye')
description = story_data.get('description', '')
author = story_data.get('user', {}).get('name', 'Bilinmeyen Yazar')
cover_url = story_data.get('cover', '')
parts = story_data.get('parts', [])

print(f"Kitap: {title} | Yazar: {author} | Bölümler: {len(parts)}")

# 4. Fəsillərin mətnlərini asinxron/paralel olaraq çək (Maksimum 1.5 saniyə)
def fetch_chapter(part):
    part_id = part['id']
    part_title = part['title']
    url = f"https://www.wattpad.com/apiv2/storytext?id={part_id}"
    try:
        r = requests.get(url, headers=headers, timeout=10)
        if r.status_code == 200:
            return {"title": part_title, "text": r.text}
    except Exception as e:
        print(f"Bölüm {part_title} çekilirken hata: {e}")
    return {"title": part_title, "text": ""}

chapters = []
print("Bölümlerin metinleri paralel olarak indiriliyor...")
with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    results = list(executor.map(fetch_chapter, parts))
    chapters = [r for r in results if r['text']]

# 5. HTML Mətnini təmizləyən köməkçi metod
def clean_html(raw_html):
    # HTML teqlərini və lazımsız boşluqları təmizləyir
    cleanr = re.compile('<.*?>')
    cleantext = re.sub(cleanr, '', raw_html)
    cleantext = html.unescape(cleantext)
    return cleantext.strip()

# 6. ReportLab ilə PDF qurulması
print("PDF dosyası oluşturuluyor...")
doc = SimpleDocTemplate(
    output_path,
    pagesize=letter,
    rightMargin=54,
    leftMargin=54,
    topMargin=54,
    bottomMargin=54
)

styles = getSampleStyleSheet()

# Xüsusi Stillərin təyini (Azeri şrift dəstəyi ilə)
title_style = ParagraphStyle(
    'BookTitle',
    parent=styles['Normal'],
    fontName=FONT_NAME,
    fontSize=26,
    leading=32,
    alignment=TA_CENTER,
    spaceAfter=15
)

author_style = ParagraphStyle(
    'BookAuthor',
    parent=styles['Normal'],
    fontName=FONT_NAME,
    fontSize=16,
    alignment=TA_CENTER,
    spaceAfter=30
)

desc_style = ParagraphStyle(
    'BookDesc',
    parent=styles['Normal'],
    fontName=FONT_NAME,
    fontSize=11,
    leading=16,
    alignment=TA_JUSTIFY,
    spaceAfter=15
)

chapter_title_style = ParagraphStyle(
    'ChapterTitle',
    parent=styles['Normal'],
    fontName=FONT_NAME,
    fontSize=18,
    leading=22,
    spaceBefore=20,
    spaceAfter=15
)

body_style = ParagraphStyle(
    'ChapterBody',
    parent=styles['Normal'],
    fontName=FONT_NAME,
    fontSize=11,
    leading=17,
    alignment=TA_JUSTIFY,
    spaceAfter=12
)

story = []

# --- 1-Cİ SƏHİFƏ: ÜZ QABIĞI (COVER) ---
# Üz qabığı şəklini endir və əlavə et
if cover_url:
    try:
        cover_path = os.path.dirname(os.path.abspath(__file__)) + f"/temp_cover_{story_id}.jpg"
        img_data = requests.get(cover_url, timeout=10).content
        with open(cover_path, "wb") as handler:
            handler.write(img_data)
        
        # Şəkli nizamla
        story.append(Spacer(1, 40))
        story.append(Image(cover_path, width=200, height=300))
        story.append(Spacer(1, 20))
    except Exception as e:
        print(f"Kapak resmi eklenemedi: {e}")
        story.append(Spacer(1, 100))
else:
    story.append(Spacer(1, 100))

story.append(Paragraph(title, title_style))
story.append(Paragraph(f"Yazar: {author}", author_style))
story.append(PageBreak())

# --- 2-Cİ SƏHİFƏ: TƏSVİR (DESCRIPTION) ---
story.append(Spacer(1, 30))
story.append(Paragraph("<b>KİTAP TANITIMI</b>", chapter_title_style))
story.append(Spacer(1, 10))

clean_desc = clean_html(description)
if clean_desc:
    story.append(Paragraph(clean_desc, desc_style))
else:
    story.append(Paragraph("Kitap açıklaması mevcut değil.", desc_style))

story.append(PageBreak())

# --- 3-CÜ SƏHİFƏ VƏ ARDI: BÖLÜMLƏR (CHAPTERS) ---
for idx, ch in enumerate(chapters):
    ch_title = clean_html(ch['title'])
    ch_text = ch['text']
    
    # Bölüm Başlığı
    story.append(Paragraph(f"<b>Bölüm {idx + 1}: {ch_title}</b>", chapter_title_style))
    story.append(Spacer(1, 15))
    
    # Mətni paraqraflara bölüb əlavə et
    paragraphs = ch_text.split('\n')
    for p in paragraphs:
        p_clean = clean_html(p)
        if p_clean:
            story.append(Paragraph(p_clean, body_style))
    
    story.append(PageBreak())

# PDF-i saxla
try:
    doc.build(story)
    print(f"Başarılı! PDF oluşturuldu: {output_path}")
    
    # Müvəqqəti üz qabığı faylını təmizlə
    temp_cover = os.path.dirname(os.path.abspath(__file__)) + f"/temp_cover_{story_id}.jpg"
    if os.path.exists(temp_cover):
        os.remove(temp_cover)
        
except Exception as e:
    print(f"PDF oluşturulurken hata meydana geldi: {e}")
    sys.exit(1)
