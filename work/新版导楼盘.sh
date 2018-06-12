"
烟台筑房/2ntoCnT2/yantzhuf/烟台/zf0609/YTZF
V3所需楼盘的IP:39.107.127.226
V3所需楼盘的名字:hamsv3_517
"
ssh 39.107.127.226 "/usr/local/mysql/bin/mysqldump -u root hamsv3_517 --tables ta_dstrict ta_picearea ta_estate ta_building ta_buildingunit ta_apartmentdistributed | gzip > /mnt/databack/hamsv3_estate.gz"
scp root@39.107.127.226:/mnt/databack/hamsv3_estate.gz .
mysql hamsv3_lp < <(zcat hamsv3_estate.gz )
mysql -f hamsv3_lp < v3lp_default.sql


ssh 114.215.141.44 "/usr/local/mysql/bin/mysqldump -h127.0.0.1 hamsv4_initwithuser > /mnt/databack/hamsv4_init.sql"
scp root@114.215.141.44:/mnt/databack/hamsv4_init.sql .
mysql hamsv4_lp < hamsv4_init.sql

mysql -e "SELECT cityid from crmv3.ta_city where cityname like '烟台%';"

"

烟台筑房/2ntoCnT2/yantzhuf/烟台/zf0609/YTZF
30f5d880-f015-11e5-94fa-687309d306a5
UPDATE hamsv4_lp.rs_company SET companyname = '烟台筑房',abbreviation='烟台筑房' ,companydesc = '2ntoCnT2', imgurl = 'http://yantzhuf.hzlysoft.net/';
update hamsv4_lp.sz_sysmomainname set domainvalue = 'http://yantzhuf.hzlysoft.net' where domainname = 'MFK';
UPDATE hamsv4_lp.sz_area set areaid='30f5d880-f015-11e5-94fa-687309d306a5',areaname='烟台',areacode=null,lngx=null,laty=null;
update hamsv4_lp.sz_systemconfig set areaid='30f5d880-f015-11e5-94fa-687309d306a5';
update hamsv4_lp.rs_systemuser set `password`=UPPER(MD5('zf0609'));
UPDATE hamsv4_lp.rs_department SET cityid = '30f5d880-f015-11e5-94fa-687309d306a5', dsid = NULL, depname = '烟台筑房', header = 'YTZF', address = NULL, spell = 'YTZF', deptnature = NULL, softname = NULL;

delete from sz_systemconfig where syspcode = 'sz' and syscode in ('500001', '500002');
insert into sz_systemconfig(sysconfigid, syscode, syspcode, itemname, itemvalue, areaid) values(UUID(), '500001', 'sz', '显示业务工作台', 0, null);
insert into sz_systemconfig(sysconfigid, syscode, syspcode, itemname, itemvalue, areaid) values(UUID(), '500002', 'sz', '显示业务工作台', 0, null);

update sz_systemconfig set areaid = null where syspcode = 'sz' and syscode in ('500001', '500002');

"

mysql hamsv4_lp < v4lp_default.sql
java -jar importEstate.jar
/usr/local/mysql/bin/mysqldump hamsv4_lp > end.sql
scp end.sql root@47.93.41.46:/mnt/databack/whhx.sql

ssh 47.93.41.46
mysql hamsv4_whhx < /mnt/databack/whhx.sql

cat << EOF > cmdb.sql
use hamsv4_whhx;
db.createUser({user: "hzlyadmin",pwd: "hzlyadmin",roles:[{role: "dbOwner",db: "hamsv4_whhx"}]})
EOF
mongo 127.0.0.1:3568 < cmdb.sql

