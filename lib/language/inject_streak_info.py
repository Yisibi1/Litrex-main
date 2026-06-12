import glob

files = glob.glob('c:/litresfer/Litrex-main (12)/Litrex-main/Litrex-main/lib/language/Language*.dart')

for f in files:
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
    except:
        with open(f, 'r', encoding='latin-1') as file:
            content = file.read()

    if 'lblStreakInfoTitle' in content: continue

    append_str = '''
  @override String get lblStreakInfoTitle => "🔥 What is a Streak?";
  @override String get lblStreakInfoMsg => "You can increase your streak by opening the app or reading a book every day.\\n\\n⚠️ Warning:\\nIf you miss 1 day, the chain will break and your streak will reset.\\n\\n🎁 Reward:\\nThe system will automatically reward you with coins when you reach certain milestones!";
'''
    
    content = content.replace('String get lblCoinsReward => "Coins";', 'String get lblCoinsReward => "Coins";\n' + append_str)
    
    try:
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
    except Exception as e:
        with open(f, 'w', encoding='latin-1') as file:
            file.write(content)
