# solr-json-repro

Setup to reproduce regression in Solr version 8.11.1 regarding JSON subfacets for analysed string field.

Link to JIRA issue: https://issues.apache.org/jira/browse/SOLR-16139

## Running the script
1. Make sure docker is installed
2. Run the init.sh script
`./init.sh`

## Additional info
After updating Solr on my dev environment to version 8.11.1 I noticed nested json stat facets where not working anymore. When downgrading to 8.11.0 worked as before.

It seems the problem is related to using an analysed string fieldtype like 'solr.SortableTextField' and then using a subfacet with a stat facet function like 'avg'.

The only change I made to the default managed-schema is to change the type of the dynamic field '*_s' to 'text_gen_sort'.
