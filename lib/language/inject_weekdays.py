import glob

files = glob.glob('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/Language*.dart')

for f in files:
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
    except:
        with open(f, 'r', encoding='latin-1') as file:
            content = file.read()

    if 'lblMon' in content: continue

    append_str = '''
  @override String get lblMon => "Mon";
  @override String get lblTue => "Tue";
  @override String get lblWed => "Wed";
  @override String get lblThu => "Thu";
  @override String get lblFri => "Fri";
  @override String get lblSat => "Sat";
  @override String get lblSun => "Sun";
'''
    
    content = content.replace('String get lblStreakInfoMsg =>', append_str + '\n  @override\n  String get lblStreakInfoMsg =>')
    
    try:
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
    except Exception as e:
        with open(f, 'w', encoding='latin-1') as file:
            file.write(content)
