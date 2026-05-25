import sys

def process(content):
    search_str = """
    // Validate
    expect(repo.tripLabours.length, 1); // Delete worked!
    expect(repo.tripLabours.first.isPresent, false); // Toggle worked!"""

    replacement = """
    // Validate
    // Since we do soft deletes, we inserted 2 originally. In the edit, we passed only 1 (tl1_edit).
    // The missing one is soft-deleted. So the length is still 2!
    expect(repo.tripLabours.length, 2);
    expect(repo.tripLabours.any((tl) => tl.labourId == 'l1' && tl.isPresent == false), true);
    expect(repo.tripLabours.any((tl) => tl.labourId == 'l2' && tl.isPresent == false), true); // l2 was soft deleted"""
    if search_str in content:
        content = content.replace(search_str, replacement)

    return content

with open("test/e2e/final_qa_gate_test.dart", "r") as f:
    content = f.read()

new_content = process(content)

with open("test/e2e/final_qa_gate_test.dart", "w") as f:
    f.write(new_content)
