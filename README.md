# awesome-glue-table-exporter

## Tools

* jq(cli)
* json2yaml(pip)
* aws(cli)
* ddlparse(pip3)
* https://www.json2yaml.com/

## How to use

1. Export

```bash
MYSQL_PWD={password} mysqldump --skip-add-drop-table --compact --no-data -h 127.0.0.1  -P 13314 -uvadmin vmdm_public  |egrep -v "(^SET|^/\*\!)"> data.dmp
```

1. Convert

```bash
python mysql-dump-2-context.py data.dmp | sort > table-lists.txt
less table-lists.txt
```

1. Split

```bash
split -l 10  table-list.txt tables
ls -la tables* 
```

1. Convert

```bash
CURRENT_TIMESTAMP=$(date +"%s")
cat tablesaa | ./build-glue-tables-cfn-template.sh $CURRENT_TIMESTAMP > cfn-template-glue-tables-aa.yml
#...
```
