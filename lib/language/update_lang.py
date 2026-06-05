import glob
import re
import os

files = glob.glob('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/Language*.dart')
for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    
    has_eula = False
    for line in lines:
        if 'lblTermsOfUseEula' in line:
            has_eula = True
            break
            
    if has_eula:
        continue
        
    out = []
    for line in lines:
        out.append(line)
        if 'String get lblTermsCondition =>' in line:
            val = line.split('=>')[1].strip().strip(';').strip('"')
            out.append('\n  @override\n')
            out.append(f'  String get lblTermsOfUseEula => "{val} (EULA)";\n')
            
    with open(f, 'w', encoding='utf-8') as file:
        file.writelines(out)

# also do LauguageTr.dart
tr_file = 'c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/LauguageTr.dart'
with open(tr_file, 'r', encoding='utf-8') as file:
    lines = file.readlines()

has_eula = False
for line in lines:
    if 'lblTermsOfUseEula' in line:
        has_eula = True
        break
        
if not has_eula:
    out = []
    for line in lines:
        out.append(line)
        if 'String get lblTermsCondition =>' in line:
            out.append('\n  @override\n')
            out.append('  String get lblTermsOfUseEula => "Kullanım Şartları (EULA)";\n')
            
    with open(tr_file, 'w', encoding='utf-8') as file:
        file.writelines(out)
