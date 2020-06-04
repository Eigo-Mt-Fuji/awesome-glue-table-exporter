#!/bin/bash

CURRENT_TIMESTAMP=$1

cat <<EOF 
AWSTemplateFormatVersion: 2010-09-09
Description: 'Creation of Glue Tables'
Parameters:
  AppName:
    Type: String
    MinLength: '1'
    Default: efg
    AllowedValues:
      - efg
  EnvName:
    Type: String
    MinLength: '1'
    AllowedValues:
      - dev
  TenantId:
    Type: String
    MinLength: '3'
    MaxLength: '3'
  GlueDatabaseName:
    Type: String
    MinLength: '1'

Metadata:
  'AWS::CloudFormation::Interface':
    ParameterGroups:
      - Label:
          default: System Name
        Parameters:
          - AppName
      - Label:
          default: Environment Configuration
        Parameters:
          - EnvName
          - TenantId
          - GlueDatabaseName

Resources:

EOF

while read line; 
do 

LOGICAL_ID=$(echo $line | cut -d" " -f1 | tr -d "_")
TABLE_NAME=$(echo $line | cut -d" " -f2)
COLUMNS=$(echo $line | cut -d" " -f3 | json2yaml | sed "s/- Name:/            - Name:/g" | sed "s/  Type:/              Type:/g")

cat <<EOF 

  $LOGICAL_ID:
    Type: AWS::Glue::Table
    Properties:
      DatabaseName: !Ref GlueDatabaseName
      CatalogId: !Ref AWS::AccountId
      TableInput:
        Owner: "hadoop"
        Name: $TABLE_NAME
        Description: $TABLE_NAME
        Parameters: {"skip.header.line.count":"0","EXTERNAL": "TRUE", "areColumnsQuoted": "true", "columnsOrdered": "true", "delimiter": ",", "typeOfData": "file"}
        TableType: "EXTERNAL_TABLE"
        StorageDescriptor:
          Location: !Sub "s3://\${TenantId}-data-\${EnvName}-\${AppName}-efgriver/$TABLE_NAME"
          InputFormat: "org.apache.hadoop.mapred.TextInputFormat"
          OutputFormat: "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
          SerdeInfo:
            SerializationLibrary: org.apache.hadoop.hive.serde2.OpenCSVSerde
            Parameters: {"escapeChar": "\\\","quoteChar": "\"","separatorChar": ",", "serialization.format": "1", "transient_lastDdlTime":"$CURRENT_TIMESTAMP"}
          Compressed: false
          NumberOfBuckets: -1
          StoredAsSubDirectories: false
          Columns:
$COLUMNS
EOF
done
