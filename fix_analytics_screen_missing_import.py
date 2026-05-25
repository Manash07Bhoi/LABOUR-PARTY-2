import sys

def process(content):
    search_str = "import 'package:labour_party/features/work/presentation/bloc/history_state.dart';"
    replacement = "import 'package:labour_party/features/work/presentation/bloc/history_state.dart';\nimport 'package:labour_party/features/work/presentation/bloc/work_state.dart';"
    if search_str in content:
        content = content.replace(search_str, replacement)
    
    return content

with open("lib/features/analytics/presentation/analytics_screen.dart", "r") as f:
    content = f.read()

new_content = process(content)

with open("lib/features/analytics/presentation/analytics_screen.dart", "w") as f:
    f.write(new_content)
