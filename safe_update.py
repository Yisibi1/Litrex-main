import glob
import os

files = glob.glob('lib/language/Language*.dart')

for f in files:
    try:
        with open(f, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        enc = 'utf-8'
    except UnicodeDecodeError:
        with open(f, 'r', encoding='latin-1') as file:
            lines = file.readlines()
        enc = 'latin-1'
        
    has_eula = any('lblTermsOfUseEula' in l for l in lines)
    if has_eula:
        continue
        
    out = []
    for line in lines:
        out.append(line)
        if 'String get lblTermsCondition =>' in line:
            val = line.split('=>')[1].strip().strip(';').strip('"').strip("'")
            out.append('\n  @override\n')
            out.append(f'  String get lblTermsOfUseEula => "{val} (EULA)";\n')
            
    with open(f, 'w', encoding=enc) as file:
        file.writelines(out)

print("Language files updated successfully.")
