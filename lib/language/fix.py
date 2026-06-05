import glob
for f in glob.glob('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/Language*.dart'):
    if f.endswith('LauguageTr.dart'): continue
    with open(f, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    if any('lblTermsOfUseEula' in l for l in lines): continue
    out = []
    for line in lines:
        out.append(line)
        if 'String get lblTermsCondition =>' in line:
            val = line.split('=>')[1].strip().strip(';').strip('"')
            out.append('\n  @override\n')
            out.append(f'  String get lblTermsOfUseEula => "{val} (EULA)";\n')
    with open(f, 'w', encoding='utf-8') as file:
        file.writelines(out)
