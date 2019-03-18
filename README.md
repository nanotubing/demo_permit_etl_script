# demo_permit_etl_script
This is an all SQL etl script transforming a shape file of demolition permits taken from [OpenDataPhilly](https://www.opendataphilly.org/dataset/building-demolitions). This data has been inserted into [Postgis](https://postgis.net) via the [QGIS](https://www.qgis.org/en/site/) DB manager. This script normalizes the starting SQL table to Third Normal Form, preserving geospatial attributes.

The full report for this project can be found on [my website](https://claudeschrader.com/etl-transformation-to-third-normal-form/)
