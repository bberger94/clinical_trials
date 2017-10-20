SCRIPT(S) FOR DATA PRE-PROCESSING

company_ancestors.R uses the dataset of firms and their "ancestors" (parents) to:

1. Assign Firm X as its own ancestor in the case that it has none.

2. Obtain ancestor IPO date and publicly traded status for each firm by merging the file onto itself.
