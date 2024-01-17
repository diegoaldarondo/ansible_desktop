import unittest
import os
from flexpatch import parse_unified_diff, apply_changes

class TestPatchApplication(unittest.TestCase):

    def setUp(self):
        # Setup common elements for tests, if necessary
        pass

    def test_basic_addition(self):
        source_file = 'test_source_addition.txt'
        patch_file = 'test_patch_addition.patch'

        with open(source_file, 'w') as f:
            f.write("Line 1\nLine 2\nLine 3\n")

        patch_content = f"""
--- a/{source_file}
+++ b/{source_file}
@@ -1,3 +1,4 @@
 Line 1
+Added Line
 Line 2
 Line 3
"""
        with open(patch_file, 'w') as f:
            f.write(patch_content)

        changes = parse_unified_diff(patch_file)
        apply_changes(source_file, changes, output_file=source_file)

        with open(source_file, 'r') as f:
            content = f.readlines()
        self.assertIn("Added Line\n", content)

        os.remove(source_file)
        os.remove(patch_file)

    def test_basic_deletion(self):
        source_file = 'test_source_deletion.txt'
        patch_file = 'test_patch_deletion.patch'

        with open(source_file, 'w') as f:
            f.write("Line 1\nLine to Delete\nLine 3\n")

        patch_content = f"""
--- a/{source_file}
+++ b/{source_file}
@@ -1,3 +1,2 @@
 Line 1
-Line to Delete
 Line 3
"""
        with open(patch_file, 'w') as f:
            f.write(patch_content)

        changes = parse_unified_diff(patch_file)
        apply_changes(source_file, changes, output_file=source_file)

        with open(source_file, 'r') as f:
            content = f.readlines()
        self.assertNotIn("Line to Delete\n", content)

        os.remove(source_file)
        os.remove(patch_file)

    def test_no_context(self):
        source_file = 'test_source_no_context.txt'
        patch_file = 'test_patch_no_context.patch'

        with open(source_file, 'w') as f:
            f.write("Line 1\nLine 2\nLine 3\n")

        patch_content = f"""
--- a/{source_file}
+++ b/{source_file}
@@ -1,3 +1,4 @@
+Added without context
 Line 1
 Line 2
 Line 3
"""
        with open(patch_file, 'w') as f:
            f.write(patch_content)

        changes = parse_unified_diff(patch_file)
        apply_changes(source_file, changes, output_file=source_file)

        with open(source_file, 'r') as f:
            content = f.readlines()
        self.assertIn("Added without context\n", content)

        os.remove(source_file)
        os.remove(patch_file)

    def test_partial_context(self):
        source_file = 'test_source_partial_context.txt'
        patch_file = 'test_patch_partial_context.patch'

        with open(source_file, 'w') as f:
            f.write("Line 1\nLine 2\nLine 3\n")

        patch_content = f"""
--- a/{source_file}
+++ b/{source_file}
@@ -2,2 +2,3 @@
 Line 2
+Added in partial context
 Line 3
"""
        with open(patch_file, 'w') as f:
            f.write(patch_content)

        changes = parse_unified_diff(patch_file)
        apply_changes(source_file, changes, output_file=source_file)

        with open(source_file, 'r') as f:
            content = f.readlines()
        self.assertIn("Added in partial context\n", content)

        os.remove(source_file)
        os.remove(patch_file)

    def test_overlapping_changes(self):
        source_file = 'test_source_overlapping.txt'
        patch_file = 'test_patch_overlapping.patch'

        with open(source_file, 'w') as f:
            f.write("Line 1\nLine 2\nLine 3\nLine 4\n")

        patch_content = f"""
--- a/{source_file}
+++ b/{source_file}
@@ -1,4 +1,5 @@
 Line 1
+Added Line
 Line 2
 Line 3
@@ -2,4 +2,5 @@
 Line 2
+Another Added Line
 Line 3
 Line 4
"""
        with open(patch_file, 'w') as f:
            f.write(patch_content)

        changes = parse_unified_diff(patch_file)
        apply_changes(source_file, changes, output_file=source_file)

        with open(source_file, 'r') as f:
            content = f.readlines()
        self.assertIn("Added Line\n", content)
        self.assertIn("Another Added Line\n", content)

        os.remove(source_file)
        os.remove(patch_file)

    def test_output_option(self):
        source_file = 'test_source_output_option.txt'
        output_file = 'test_output.txt'
        patch_file = 'test_patch_output_option.patch'

        with open(source_file, 'w') as f:
            f.write("Original Line 1\nOriginal Line 2\n")

        patch_content = f"""
--- a/{source_file}
+++ b/{output_file}
@@ -1,2 +1,3 @@
 Original Line 1
+Added Line
 Original Line 2
"""
        with open(patch_file, 'w') as f:
            f.write(patch_content)

        changes = parse_unified_diff(patch_file)
        apply_changes(source_file, changes, output_file=output_file)

        with open(output_file, 'r') as f:
            content = f.readlines()
        self.assertIn("Added Line\n", content)

        os.remove(source_file)
        os.remove(output_file)
        os.remove(patch_file)

    # Additional test methods for other scenarios can be added here

    def tearDown(self):
        # Any cleanup after each test, if necessary
        pass

if __name__ == '__main__':
    unittest.main()
