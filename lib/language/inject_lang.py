import glob

base_file = 'c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/BaseLanguage.dart'
with open(base_file, 'r', encoding='utf-8') as f:
    content = f.read()
if 'lblReadingMode' not in content:
    content = content.replace('String get lblLanguageDesc;', 'String get lblLanguageDesc;\n\n  // Reading Settings\n  String get lblReadingMode;\n  String get lblScrollDirection;\n  String get lblVertical;\n  String get lblHorizontal;\n  String get lblFullScreen;')
    with open(base_file, 'w', encoding='utf-8') as f:
        f.write(content)

files = glob.glob('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/Language*.dart')
files.append('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/LauguageTr.dart')

for f in files:
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
    except UnicodeDecodeError:
        with open(f, 'r', encoding='latin-1') as file:
            content = file.read()

    if 'lblReadingMode' in content: continue

    is_tr = 'LauguageTr.dart' in f
    lblReadingMode = 'Oxuma Rejimi' if is_tr else 'Reading Mode'
    lblScrollDirection = 'Sürüşdürmə Yönü' if is_tr else 'Scroll Direction'
    lblVertical = 'Aşağı/Yuxarı' if is_tr else 'Vertical'
    lblHorizontal = 'Sağa/Sola' if is_tr else 'Horizontal'
    lblFullScreen = 'Tam Ekran' if is_tr else 'Full Screen'
    
    append_str = f'''
  @override
  String get lblReadingMode => "{lblReadingMode}";
  @override
  String get lblScrollDirection => "{lblScrollDirection}";
  @override
  String get lblVertical => "{lblVertical}";
  @override
  String get lblHorizontal => "{lblHorizontal}";
  @override
  String get lblFullScreen => "{lblFullScreen}";
'''
    
    content = content.replace('String get lblLanguageDesc =>', append_str + '\n  @override\n  String get lblLanguageDesc =>')
    
    try:
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
    except Exception as e:
        with open(f, 'w', encoding='latin-1') as file:
            file.write(content)
