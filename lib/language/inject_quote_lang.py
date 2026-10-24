import glob

files = glob.glob('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/Language*.dart')
files.append('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/LauguageTr.dart') # Note typo Lauguage

def process_file(f):
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
    except:
        with open(f, 'r', encoding='latin-1') as file:
            content = file.read()

    if 'lblDesignQuote' in content: return

    is_tr = 'LauguageTr.dart' in f
    is_az = 'LanguageAz.dart' in f # If exists
    
    # Defaults (English for others, Turkish for Tr)
    val_designQuote = "Alıntıyı Tasarla" if (is_tr or is_az) else "Design Quote"
    val_quoteDesigner = "Alıntı Stüdyosu" if (is_tr or is_az) else "Quote Studio"
    val_chooseBackground = "Arka Plan Seçin" if (is_tr or is_az) else "Choose Background"
    val_shareAsImage = "Görsel Olarak Paylaş" if (is_tr or is_az) else "Share as Image"
    val_myQuotes = "Alıntılarım" if (is_tr or is_az) else "My Quotes"
    val_noQuotesFound = "Henüz bir alıntı kaydetmediniz." if (is_tr or is_az) else "You haven't saved any quotes yet."

    append_str = f'''
  // Quotes
  @override String get lblDesignQuote => "{val_designQuote}";
  @override String get lblQuoteDesigner => "{val_quoteDesigner}";
  @override String get lblChooseBackground => "{val_chooseBackground}";
  @override String get lblShareAsImage => "{val_shareAsImage}";
  @override String get lblMyQuotes => "{val_myQuotes}";
  @override String get lblNoQuotesFound => "{val_noQuotesFound}";
'''
    
    content = content.replace('String get lblStreakDetails =>', append_str + '\n  @override String get lblStreakDetails =>')
    
    try:
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
    except Exception as e:
        with open(f, 'w', encoding='latin-1') as file:
            file.write(content)

for f in files:
    process_file(f)

# Update BaseLanguage.dart
base_f = 'c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/BaseLanguage.dart'
with open(base_f, 'r', encoding='utf-8') as file:
    base_content = file.read()

if 'lblDesignQuote' not in base_content:
    base_append = '''
  // Quotes
  String get lblDesignQuote;
  String get lblQuoteDesigner;
  String get lblChooseBackground;
  String get lblShareAsImage;
  String get lblMyQuotes;
  String get lblNoQuotesFound;
'''
    base_content = base_content.replace('String get lblStreakDetails;', base_append + '\n  String get lblStreakDetails;')
    with open(base_f, 'w', encoding='utf-8') as file:
        file.write(base_content)

print("Language injection complete.")
