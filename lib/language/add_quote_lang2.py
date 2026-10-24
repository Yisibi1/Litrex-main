import glob

files = glob.glob('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/Language*.dart')
files.append('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/LauguageTr.dart')

def process_file(f):
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
    except:
        with open(f, 'r', encoding='latin-1') as file:
            content = file.read()

    if 'lblNoQuoteForThisBook' in content: return

    is_tr = 'LauguageTr.dart' in f
    
    val_noQuote = "Bu kitaba ait alıntı yok" if is_tr else "No quotes for this book"
    val_delTitle = "Silmek istediğinize emin misiniz?" if is_tr else "Are you sure you want to delete?"
    val_delMsg = "Bu alıntı silinecek." if is_tr else "This quote will be deleted."

    append_str = f'''
  @override String get lblNoQuoteForThisBook => "{val_noQuote}";
  @override String get lblDeleteQuoteConfirmTitle => "{val_delTitle}";
  @override String get lblDeleteQuoteConfirmMsg => "{val_delMsg}";
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

if 'lblNoQuoteForThisBook' not in base_content:
    base_append = '''
  String get lblNoQuoteForThisBook;
  String get lblDeleteQuoteConfirmTitle;
  String get lblDeleteQuoteConfirmMsg;
'''
    base_content = base_content.replace('String get lblStreakDetails;', base_append + '\n  String get lblStreakDetails;')
    with open(base_f, 'w', encoding='utf-8') as file:
        file.write(base_content)

print("Language injection complete.")
