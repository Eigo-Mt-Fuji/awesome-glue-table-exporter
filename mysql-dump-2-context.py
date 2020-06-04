from ddlparse.ddlparse import DdlParse
import stringcase
import json

f = open("./vmdm_public.dmp", "r")
ddl_text=f.read()
ddls = ddl_text.split(";")

for index, ddl in enumerate(ddls):
    if ddl.find("CREATE TABLE") != -1:
        try:
            table = DdlParse().parse(ddl=ddl)
            logical_id = stringcase.alphanumcase(
                stringcase.capitalcase(stringcase.camelcase(table.name))
            )
            table_name = table.name
            columns = list(map(lambda col: {"Name":col.name.lower(),"Type":"string"}, table.columns.values()))
            columns_json = json.dumps(columns, separators=(',', ':'))
            print("{logical_id} {table_name} {columns_json}".format(logical_id = logical_id, table_name = table_name, columns_json = columns_json))
        except Exception as e:
            print(index)
            print(value)
            print(e)

