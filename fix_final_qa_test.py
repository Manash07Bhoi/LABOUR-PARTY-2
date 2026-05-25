import sys

def process(content):
    # Fix the test logic since we changed SaveFullWorkTripEvent to do soft deletes
    search_str = """    // Verify lengths did not duplicate orphaned records
    expect(repo.works.length, 1);
    expect(repo.trips.length, 1);
    expect(
      repo.labours.length,
      2,
    ); // Labour entities persist globally historically
    expect(
      repo.tripLabours.length,
      1,
    ); // TripLabour replaced l1 with l2 cleanly
    expect(repo.tripLabours.first.labourId, 'l2');"""

    replacement = """    // Verify lengths did not duplicate orphaned records
    expect(repo.works.length, 1);
    expect(repo.trips.length, 1);
    expect(
      repo.labours.length,
      2,
    ); // Labour entities persist globally historically
    expect(
      repo.tripLabours.length,
      2,
    ); // TripLabour soft deletes old record (isPresent=false), keeps new one
    expect(repo.tripLabours.any((tl) => tl.labourId == 'l2' && tl.isPresent), true);
    expect(repo.tripLabours.any((tl) => tl.labourId == 'l1' && !tl.isPresent), true);"""
    
    if search_str in content:
        content = content.replace(search_str, replacement)
        
    search_str2 = "expect(repo.tripLabours.length, 2);"
    replacement2 = "expect(repo.tripLabours.length, 3);"
    
    if search_str2 in content:
        content = content.replace(search_str2, replacement2)
    return content

with open("test/integration/final_manual_qa_simulation_test.dart", "r") as f:
    content = f.read()

new_content = process(content)

with open("test/integration/final_manual_qa_simulation_test.dart", "w") as f:
    f.write(new_content)
