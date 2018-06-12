-- <2014-11-14>删除审批流程表中的remark字段
    alter table ta_workflow drop column remark;
-- <2014-11-14>新版详情界面上线后，需要统一修改附件类型（分支代码）
    update ta_attachment set phototype='402881f64955b7f1014956201aa40008' where phototype='房源勘察照片';
    update ta_house ths set ths.photocount=(select count(*) from ta_attachment tat where tat.belongid=ths.houseid and tat.phototype='402881f64955b7f1014956201aa40008');
-- <2014-11-14>调整了物业参数模块，需要修改物业参数数据(分支代码)
    -- 在物业参数显示销售阶段
    update ta_reference set pid='4aea439e3e1fd314013e214d509f0170' where refid='4aea439e3e1fd314013e2153c9630175';
    -- 从字典表删除销售环节
    delete from ta_reference where refname='SalesLink';
    -- 把客户自己增加的物业参数设置成可修改，可删除状态
    update ta_reference set flagallowdel='1',flagallowmod='1' where flagtrashed is null;
    -- 把系统原有参数设置成不可修改，不可删除状态
    update ta_reference set flagallowdel='0',flagallowmod='0' where flagtrashed is not null;
    -- 把所有参数的设置成未删除，未废弃
    update ta_reference set flagdeleted='0',flagtrashed='0';
    -- 设置除带看，签合同，未成交外可修改项目值
    update ta_reference set flagallowmod='1' where refid<>'4aea439e3e1fd314013e2155e6a10182' and refid<>'4aea439e3e1fd314013e21561b870184' and refid<>'8b2881e64843b741014844d9252d0002'
    and refname='Salesprocess' and itemvalue is not null;
    -- 设置结佣可删除
    update ta_reference set flagallowdel='1' where refid='4aea439e3e1fd314013e21562b270185';
    -- 设置履约结盘可删除
    update ta_reference set flagallowdel='1' where refid='4aea439e3e1fd314013e21563b270185';
    -- 删除探索跟进
    update ta_reference set flagtrashed='1',flagdeleted='1' where refid='402881e6475bfe5601475d278deb003c';
    -- 在物业参数里的销售阶段中注掉需求挖掘
    update ta_reference set flagallowmod= '-1' where refid='4aea439e3e1fd314013e2155be7f0180';
-- <2014-11-14>生成新的单元遮盖权限
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate)
    select UUID(),uid,'100205',authcodevalue,'1',NOW() from ta_personauthority where authcode='100201';
-- <2014-11-19>调整物业参数（分支代码）
    --  地下室类型  商铺 写字楼 车位 产房    修改父id 把这些中类型放在其他房源下
    UPDATE ta_reference set pid = '4aea439e3e1fd314013e24e126d701a6' where (refname='BasementType' OR refname='ShopType' OR refname='OfficeType' OR refname='ParkLocation' OR refname='FactoryType') and itemno is null and itemvalue is null;
    -- 写字楼 厂房仓库 土地 车位  商铺    修改标识  把原其他房源的下 字典 删除
    UPDATE ta_reference set flagdeleted ='1' ,flagtrashed ='1' where (refname='OfficeBuilding' OR refname='FactoryStorehouse' OR refname='Land' OR refname='Parking' OR refname='Shops') AND itemno is null and itemvalue is null;
-- <2014-11-21>更新权限，有没有控制权限的权限（分支代码）
    update ta_personauthority set authcodevalue=4 where authcode='500907' and authcodevalue=3;
    update ta_personauthority set authcodevalue=3 where authcode='500907' and authcodevalue=2;
    update ta_postauthority set authcodevalue=4 where authcode='500907' and authcodevalue=3;
    update ta_postauthority set authcodevalue=3 where authcode='500907' and authcodevalue=2;
-- <2014-12-07>转盘申请、转客申请功能修改后，原来的数据存在问题，需要为<转至状态>和<转至公私特性>设置默认值
    update ta_workflow tw ,ta_workstep ts,ta_approvaopinion ta,ta_house th set ta.tradestatusnew=th.tradestatus,ta.privynew=th.privy
    where tw.workflowid=ts.workflowid and ts.workstepid=ta.workstepid and tw.businessentityid=th.houseid and ta.tradestatusnew is null;
    update ta_workflow tw ,ta_workstep ts,ta_approvaopinion ta,ta_inquiry th set ta.tradestatusnew=th.`status`,ta.privynew=th.custfeatrue
    where tw.workflowid=ts.workflowid and ts.workstepid=ta.workstepid and tw.businessentityid=th.inquiryid and ta.tradestatusnew is null;
-- <2014-12-11>核心改版，更新性别（分支代码）
    update ta_systemuser  set sex=SUBSTRING(sex, 1,1);
-- <2014-12-12>修改申请转盘生成的系统跟进，原来的部门和员工存的是受理人的，改为发起人的（分支代码）
    update ta_followsys tf left join ta_informationstation ti on tf.houseid=ti.houseid set tf.empid=IFNULL(ti.sendempid,tf.empid) ,tf.deptid=IFNULL(senddeptid,tf.deptid)
    where tf.empid<>ti.sendempid and ti.intelligencetitle='申请转盘' and DATE_FORMAT(tf.followdate,'%Y%m%d %H:%i')=DATE_FORMAT(ti.createtime,'%Y%m%d %H:%i');
-- <2014-12-15>更新地铁、环线物业参数（分支代码）
    -- 删除原地铁下所有城市
    delete from ta_reference where pid='8a01ad764148bbba01415d81d69c67ea';
    -- 关联城市表在地铁下新增城市
    insert into ta_reference select uuid(),'8a01ad764148bbba01415d81d69c67ea',null,areaname,'01',null,areaid,NOW(),0,0,0,0 from ta_area;
    -- 更新原地铁线路，修改pid为当前城市id,refname为subway_+当前城市id
    update ta_reference tr,(select b.areaid,a.refid from  ta_reference a , ta_area b where a.iteminfo=b.areaid ) c
    set tr.pid=c.refid,tr.refname=CONCAT('subway_' ,c.areaid) where tr.refname='beijing';
    -- 更新环线
    delete from ta_reference where pid='8a01ad764148bbba01415d83a41967eb';
    insert into ta_reference select uuid(),'8a01ad764148bbba01415d83a41967eb',null,areaname,'01',null,areaid,NOW(),0,0,0,0 from ta_area;
    update ta_reference tr,(select b.areaid,a.refid from  ta_reference a , ta_area b where a.iteminfo=b.areaid ) c
    set tr.pid=c.refid,tr.refname=CONCAT('ring_' ,c.areaid) where tr.refname='bj';
-- <2014-12-25>修改户型图照片url
    update ta_apartmentlayout set photourl=RIGHT(photourl,LENGTH(photourl)-LOCATE('uploadfile',photourl)+1);
    update ta_attachment set attachurl=RIGHT(attachurl,LENGTH(attachurl)-LOCATE('uploadfile',attachurl)+1),smallurl=RIGHT(smallurl,LENGTH(smallurl)-LOCATE('uploadfile',smallurl)+1);
-- <2015-01-05>楼盘销控模块需要转移到销售管理下（分支代码）
    update ta_sysmodule set pid='30',modulecode='3013',sort='422' where sysmoduleid = 'e3c5c44b-13c8-11e4-85a9-43d872b42dc6';
    update ta_postmodel set sysmoduleid='3013' where sysmoduleid='7014';
-- <2015-01-07>修改公司信息，从部门表同步到公司表
    UPDATE ta_company c,ta_department d SET c.companyname = d.depname,c.adress = d.address,c.phone = d.tel,c.manifesto = d.manifesto,
    c.briefintroduction = d.briefintroduction,c.logo = d.logo,c.cox=d.cox,c.coy=d.coy WHERE d.pid = d.deptid;
-- <2015-01-07>执行代码生成查重的部门权限
*   RepeatQuanxianProcess
-- <2015-01-14>数据库结构修改，删除无用字段
    -- 删除审批流程表的备注字段
    alter table ta_workflow drop column remark;
    -- 删除责任盘指标表中的市占率指标字段
    alter table ta_dutyflagindicators drop column szlzb;
-- <2015-01-21>数据库结构修改，删除无用字段
    -- 删除资料客源表的无用字段
    alter table ta_inquirydata drop column countf;
    alter table ta_inquirydata drop column countt;
    alter table ta_inquirydata drop column countw;
    alter table ta_inquirydata drop column county;
-- <2015-01-23>更新资料房源楼盘、栋座、单元名
    update ta_propertydata a,ta_estate b set a.estatename=b.estatename where a.estateid=b.estateid;
    update ta_propertydata a,ta_building b set a.buildingname=b.buildingname where a.buildid=b.buildingid;
    update ta_propertydata a,ta_buildingunit b set a.unitname=b.unitname where a.unint=b.unitid;
-- <2015-01-30>个人组织机构权限中需要添加一项“无”，将编码往后移一位
    update ta_personauthority set authcodevalue=authcodevalue+1 where authcode in ('50040301','50040701');
-- <2015-03-02>附件表图片类型<楼盘平面图>改为编码
    update ta_attachment set phototype='586ff86e3fe1084f013fea515f8d0017' where phototype='楼盘平面图';
-- <2015-03-03>增加新增跟进时的<跟进人选择>权限
    insert into ta_personauthority select UUID(),uid,'100412','2','1',NOW(),null from ta_systemuser where flagdeleted=0;
-- <2015-03-05>更新房源标题字段
    update ta_house ths left join ta_estate tet on ths.estid=tet.estateid set title=CONCAT(tet.estatename,case when ths.countf is null or ths.countf='' then 0 else     ths.countf end,'室',IFNULL(ths.square,0),'㎡') where ths.title is null or ths.title='';
-- <2015-03-09>修改发布到外网权限
    update ta_personauthority set authcodevalue='4' where authcode='100145' and authcodevalue='1';
-- <2015-03-12>修改模块编码
    update ta_sysmodule set modulecode='4004' where modulename='流程列表';
-- <2015-03-19>端口注册信息表删除标识字段，设置默认值0，然后根据CRM中的信息把删除的端口置为1
    update ta_pcreginfo set flagdeleted=0 where flagdeleted is null;
    -- 下边这一条查询语句在crm中执行
*   select identification from ta_port where cuid='' and flagdeleted=1;
    update ta_pcreginfo set flagdeleted=1 where identification in();
-- <2015-03-28>更新包税费字段
    update ta_houseprice ti LEFT JOIN ta_reference tf on ti.propertytax=tf.itemvalue
    and tf.refname='PropertyTax' set ti.propertytax=IFNULL(tf.refid,ti.propertytax) where ti.houseid is not null and tf.refname='PropertyTax';
-- <2015-04-09>增加了经营分析导出权限，需要统一生成
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate)
    select UUID(),uid,'600901','1','1',NOW() from ta_personauthority where authcode='6009' and authcodevalue<>'1';
-- <2015-04-16>更新跟进中新增加的客源冗余字段
    update ta_follow tf left join ta_inquiry ti on tf.inquiryid=ti.inquiryid
    set tf.custfeatrue=IFNULL(ti.custfeatrue,tf.custfeatrue),tf.inquirydeptid=ti.deptid,tf.inquiryempid=ti.gsempid;
    update ta_followother tf left join ta_inquiry ti on tf.inquiryid=ti.inquiryid
    set tf.custfeatrue=IFNULL(ti.custfeatrue,tf.custfeatrue),tf.inquirydeptid=ti.deptid,tf.inquiryempid=ti.gsempid;
    update ta_followsys  tf left join ta_inquiry ti on tf.inquiryid=ti.inquiryid
    set tf.custfeatrue=IFNULL(ti.custfeatrue,tf.custfeatrue),tf.inquirydeptid=ti.deptid,tf.inquiryempid=ti.gsempid;
-- <2015-04-17>更新跟进中新增加的客源冗余字段
    update ta_follow tf left join ta_emplyee te on tf.inquiryempid=te.empid set tf.inquiryempstatus=IFNULL(te.status,tf.inquiryempstatus);
    update ta_followother tf left join ta_emplyee te on tf.inquiryempid=te.empid set tf.inquiryempstatus=IFNULL(te.status,tf.inquiryempstatus);
    update ta_followsys tf left join ta_emplyee te on tf.inquiryempid=te.empid set tf.inquiryempstatus=IFNULL(te.status,tf.inquiryempstatus);
-- <2015-04-23>修改spring-base文件
    增加或修改清理memcached缓存的定时器
-- <2015-04-27>聚焦房将qualityhouse设置为2
    update ta_house set qualityhouse=2 where houseid IN
    (select houseid from ta_housestatusdetails where refname='4aea439e3e1fd314013e214528650143');
-- <2015-04-29>私盘特盘封盘权限拆分，更新权限
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate)
    select UUID(),uid,'101110',authcodevalue,'1',NOW() from ta_personauthority where authcode='101109';
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate)
    select UUID(),uid,'101111',authcodevalue,'1',NOW() from ta_personauthority where authcode='101109';
-- <2015-05-11>楼盘字典的物业管理费单位，统一更新为默认值
    update ta_estate set mgtunit='元/平/月';
-- <2015-06-01>楼盘字典的产权字段改为土地使用年限，需修改物业参数
    update ta_reference f set f.refnamecn='土地使用年限' where f.refname='PropertyTimeSpan' and (f.refnamecn='产权时间' or f.refnamecn='产权年限');
    update ta_operatelog o set o.content=replace(o.content,'产权','土地使用年限')  where o.belongtablename='ta_estate';
-- <2015-06-03>增加房源勘察，移动意向记录模块，增加权限
    INSERT INTO `ta_sysmodule` (`sysmoduleid`, `modulename`, `moduleurl`, `shortname`, `pid`, `modulecode`, `sort`, `reportflag`) VALUES ('fe7482df041011e580651db73f17b649', '勘察记录', '/housemanage/housesurvey!surveyList.do', '勘察记录', '10', '1004', 213, NULL);
    update ta_sysmodule set sort='214' where modulename='意向记录' and pid='10';
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate) select UUID(),uid,'1012118','4','1',NOW() from ta_personauthority where authcode='100101';
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate) select UUID(),uid,'1012119','4','1',NOW() from ta_personauthority where authcode='100101';
-- <2015-06-04>增加选项设置<首次勘察默认勘察归属人>
    INSERT INTO `ta_systemconfig` VALUES ('2ca11928-0a67-11e5-8065-1db73f17b649', '100642', '1006', '首次勘察默认勘察归属人', '1', '0', '10', 'qita1006');
-- <2015-06-10>更新托管合同和出租合同的付款方式字段
    -- 更新托管合同
    UPDATE ta_trusteeshipcontract tr LEFT JOIN ta_reference trf ON tr.paymentmode = trf.refid SET tr.paymentmode = ifnull(trf.refnamecn,tr.paymentmode);
    UPDATE ta_trusteeshipcontract tr LEFT JOIN ta_reference trf ON tr.paymentmode = trf.refnamecn AND trf.refname = 'rentpayment' SET tr.paymentmode = ifnull(trf.refid,tr.paymentmode);
    -- 更新承租合同
    UPDATE ta_rentconinfo tr LEFT JOIN ta_reference trf ON tr.paymentmode = trf.refid SET tr.paymentmode = ifnull(trf.refnamecn,tr.paymentmode);
    UPDATE ta_rentconinfo tr LEFT JOIN ta_reference trf ON tr.paymentmode = trf.refnamecn AND trf.refname = 'rentpayment' SET tr.paymentmode = ifnull(trf.refid,tr.paymentmode);
-- <2015-06-25>修改选项设置<首次勘察默认勘察归属人>的值，除<天津佳诺>
    update ta_systemconfig set itemvalue='1' where syscode='100642';
-- <2015-07-14>增加选项设置<房源转盘数量限制>
    INSERT INTO ta_systemconfig(sysconfigid,syscode,syspcode,itemname,itemvalue,itemdesc,partcode,itemename) VALUES ('8413f220-29d6-11e5-9419-00163e003a08',100407,1004,'房源转盘数量限制',0,0,10,'fangyuan4007');
-- <2015-07-22>初始化权限
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate)
    select UUID(),uid,'100150',authcodevalue,'4',NOW() from ta_personauthority where authcode = '100101';
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate)
    select UUID(),uid,'200150',authcodevalue,'4',NOW() from ta_personauthority where authcode = '100101';
-- <2015-07-23>修改模块名，修改岗位模块等级
    update ta_sysmodule set modulename='资源查重',shortname='资源查重' where shortname='房客查重';
    update ta_positionmodel set postlevel=1;
-- <2015-07-28 >修改是否落户字段的类型
    alter table ta_house MODIFY COLUMN residentflag VARCHAR(40);
    alter table ta_house_his MODIFY COLUMN residentflag VARCHAR(40);
-- <2015-07-29>更新借钥匙登记人和还钥匙登记人
    update ta_keyrecord tak left join ta_systemuser ts on tak.lentregperson=ts.chname left join ta_emplyee tee on ts.uid=tee.uid set lentregperson=IFNULL(tee.empid,tak.lentregperson);
    update ta_keyrecord tak left join ta_systemuser ts on tak.returnregperson=ts.chname left join ta_emplyee tee on ts.uid=tee.uid set returnregperson=IFNULL(tee.empid,tak.returnregperson);
-- <2015-07-30>更新钥匙借出和归还时间
    update ta_keyrecord set lentregdate=lenttime where lentregdate is null;
    update ta_keyrecord set returnregdate=returntime where returnregdate is null;
-- <2015-08-13>初始化钥匙查看权限
    INSERT INTO ta_personauthority SELECT UUID(), uid, '101004', '4', '1', NOW(), NULL FROM ta_systemuser WHERE flagdeleted = 0;
-- <2015-08-24>初始化转公盘权限
    INSERT INTO ta_personauthority SELECT UUID(), uid, '100308', '1', '1', NOW(), NULL FROM ta_systemuser WHERE flagdeleted = 0;
    INSERT INTO ta_personauthority SELECT UUID(), uid, '100305', '1', '1', NOW(), NULL FROM ta_systemuser WHERE flagdeleted = 0;
    INSERT INTO ta_personauthority SELECT UUID(), uid, '100309', '1', '1', NOW(), NULL FROM ta_systemuser WHERE flagdeleted = 0;
-- <2015-08-25>初始化转公盘权限
    INSERT INTO ta_personauthority SELECT UUID(), uid, '100113', '4', '1', NOW(), NULL FROM ta_systemuser WHERE flagdeleted = 0;
-- <2015-08-26>增加房源取代选项设置
    INSERT INTO ta_systemconfig VALUES('6b6264cb-47b4-11e5-b7be-044758e5769e',100650,1006,'房源取代非有效',0,0,10,'fyqd');
    INSERT INTO ta_systemconfig VALUES('c93f7425-47b4-11e5-b7be-044758e5769e',100651,1006,'房源取代公共账户',0,0,10,'fyqd');
    INSERT INTO ta_systemconfig VALUES('cf27c375-47b3-11e5-b7be-044758e5769e',100652,1006,'房源取代公盘',0,0,10,'fyqd');
    INSERT INTO ta_systemconfig VALUES('e0068583-47b4-11e5-b7be-044758e5769e',100653,1006,'房源取代私盘',0,0,10,'fyqd');
    INSERT INTO ta_systemconfig VALUE('d458a295-4b91-11e5-b7be-044758e5769e',200511,2005,'客源取代非有效',0,0,10,'kyqd');
    INSERT INTO ta_systemconfig VALUE('ed9d6c79-4b91-11e5-b7be-044758e5769e',200512,2005,'客源取代公客',0,0,10,'kyqd');
    INSERT INTO ta_systemconfig VALUE('0d34b63a-4b92-11e5-b7be-044758e5769e',200513,2005,'客源取代私客',0,0,10,'kyqd');
    INSERT INTO ta_systemconfig VALUE('e32564f9-4bc7-11e5-b7be-044758e5769e',200514,2005,'客源取代公共账户',0,0,10,'kyqd');
-- <2015-08-31>增加钥匙归属人选项设置
    INSERT INTO ta_systemconfig VALUES ('53b76a64-4c87-11e5-8928-00163e003a08',100643,1006,'首次钥匙登记默认钥匙归属人',0,0,10,'qita0643');
-- <2015-08-31>默认勾选新增合同关联房客源电话 ，除<山东中住>
    update ta_systemconfig set itemvalue='1' where syscode in ('300101','300102');
-- <2015-09-06>工作日日不显示客源探索跟进
    update ta_dailyfollow set followtype='4aea439e3e1fd314013e21556008017e' where followid not in (select followid from ta_follow);
-- <2015-09-08>增加合同跟进功能模块
    INSERT INTO `ta_sysmodule` VALUES ('64559a60-4a34-11e5-b7be-044758e5769e','跟进记录', '/contract/contractionfo!ContractFollowLog.do', '跟进记录', '40', '4011', '521', null);
-- <2015-09-17>增加业绩排行榜选项设置
    INSERT into ta_systemconfig  (select 'ec068b21-5d00-11e5-8928-00163e003a08',400136,4001,'业绩排行榜部门显示前[3]名',itemvalue,0,10,'qita1036' from ta_systemconfig where syscode='400119');
-- <2015-09-21>初始批量资料房源权限
    INSERT INTO ta_personauthority SELECT UUID(), uid, '500614', '1', '6', NOW(), NULL FROM ta_systemuser WHERE flagdeleted = 0;
-- <2015-09-22>增加新增合同隐藏房源详细地址选项
    INSERT into ta_systemconfig VALUES ('41707682-60f8-11e5-8928-00163e003a08',300105,3001,'新增合同隐藏房源详细地址',0,0,10,'hetong1005');
-- <2015-09-22>增加云通讯回调表
    CREATE TABLE `ta_callhangup` (
      `callhangupid` varchar(40) NOT NULL,
      `action` varchar(40) DEFAULT NULL,
      `type` varchar(40) DEFAULT NULL,
      `subid` varchar(40) DEFAULT NULL,
      `caller` varchar(40) DEFAULT NULL,
      `called` varchar(40) DEFAULT NULL,
      `starttime` datetime DEFAULT NULL,
      `endtime` datetime DEFAULT NULL,
      `billdata` varchar(40) DEFAULT NULL,
      `subtype` varchar(40) DEFAULT NULL,
      `callsid` varchar(40) DEFAULT NULL,
      `recordurl` varchar(200) DEFAULT NULL,
      `byetype` varchar(40) DEFAULT NULL,
      PRIMARY KEY (`callhangupid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- <2015-09-24>增加云通讯选项设置
    insert into ta_systemconfig values ('0935024e-6011-11e5-922d-5aba99cd38b2','100654','1006','启用云通讯','0','0','10','fy');
    insert into ta_systemconfig values ('5ba4be57-6011-11e5-922d-5aba99cd38b2','100655','1006','启用录音','0','0','10','fy');
    insert into ta_systemconfig values ('5c29fadd-601e-11e5-922d-5aba99cd38b2','100656','1006','启用录音[]秒内通话不记录','0','0','10','fy');
    insert into ta_systemconfig values ('4e7a446c-601e-11e5-922d-5aba99cd38b2','100657','1006','录音显示时间为','0','0','10','fy');
-- <2015-10-10>栋座增加户数字段
    alter table ta_building  add COLUMN room int;
    update ta_building a set room =(select count(ta.roomno) from ta_apartmentdistributed ta  where ta.buildingid=a.buildingid GROUP BY ta.buildingid);
-- <2015-10-13>统一跟进表和跟进历史表的表结构
    ALTER TABLE ta_follow_his CHANGE propertyusage propertyusage VARCHAR(40) after processdate;
    ALTER TABLE ta_follow_his CHANGE houseunit houseunit VARCHAR(40) after mediateid;
    ALTER TABLE ta_follow_his CHANGE inquiryempstatus inquiryempstatus VARCHAR(40) after inquiryempid;
    ALTER TABLE ta_follow_his MODIFY houseid VARCHAR(40) null;
    ALTER TABLE ta_followother_his CHANGE inquiryempstatus inquiryempstatus VARCHAR(40) after inquiryempid;
    ALTER TABLE ta_followsys_his CHANGE inquiryempstatus inquiryempstatus VARCHAR(40) after inquiryempid;
-- <2015-10-27>合同流程明细表增加流程步骤定义id外键字段
    alter table ta_confpdetails add COLUMN stepid VARCHAR(40);
-- <2015-11-20>修改客源表房型(房)字段类型
    alter table ta_inquiry modify countf varchar(40);
-- <2015-11-30>增加微信改版相关字段
    ALTER TABLE ta_company ADD wxappid VARCHAR(40);
    ALTER TABLE ta_company ADD wxappsecret VARCHAR(40);
-- <2015-12-02>增加跟进归档时间的系统配置项
    INSERT INTO ta_systemconfig VALUES('5cd7211c-990b-11e5-9974-00163e0220e6','400445','4001','跟进超过指定时间自动转入跟进历史','90','0','10','qita');
-- <2015-12-24>房源表增加字段
    alter table ta_house add column privydate datetime;
-- <2016-01-06>楼盘价格走势增加城市id字段
    ALTER table ta_estatetrend add COLUMN cityid VARCHAR(40);
    update ta_estatetrend ts left join ta_estate te on ts.estateid=te.estateid left join ta_picearea tp on te.areaid=tp.areaid left join ta_dstrict td on tp.dsid=td.dsid set ts.cityid = IFNULL(ts.cityid,td.areaid);
-- <2016-01-12>增加权限，交易合同分出租出售
    INSERT INTO ta_personauthority (uid,pauthorid,authcode,authcodevalue,isvalid,createdate)
    (SELECT DISTINCT p.uid,UUID(),'601004','1','4',DATE_FORMAT(NOW(),'%Y-%m-%d') FROM ta_personauthority p WHERE p.authcode = '30010102');
    INSERT INTO ta_personauthority (uid,pauthorid,authcode,authcodevalue,isvalid,createdate)
    (SELECT DISTINCT p.uid,UUID(),'601005','1','4',DATE_FORMAT(NOW(),'%Y-%m-%d') FROM ta_personauthority p WHERE p.authcode = '30010102');
    INSERT INTO ta_postauthority(ptmid,poauthid,authcode,authcodevalue,isvalid,createdate,modidate)
    (SELECT DISTINCT t.ptmid,UUID(),'601004','1','4',DATE_FORMAT(NOW(),'%Y-%m-%d'),DATE_FORMAT(NOW(),'%Y-%m-%d') FROM ta_postauthority t WHERE t.authcode = '30010102');
    INSERT INTO ta_postauthority(ptmid,poauthid,authcode,authcodevalue,isvalid,createdate,modidate)
    (SELECT DISTINCT t.ptmid,UUID(),'601005','1','4',DATE_FORMAT(NOW(),'%Y-%m-%d'),DATE_FORMAT(NOW(),'%Y-%m-%d') FROM ta_postauthority t WHERE t.authcode = '30010102');
-- <2016-01-21>部门业绩表增加岗位模板id字段
    alter table ta_performancebelong add COLUMN ptmid VARCHAR(40);
-- <2016-02-25>薪资第三版需要更新的数据
    update ta_percentage tp left join ta_post tos on tp.duty=tos.poid set tp.duty=IFNULL(tos.ptmid,tp.duty);
    update ta_performancebelong tp left join ta_emplyee tee on tp.empid = tee.empid left join  ta_user_post tps on tee.uid=tps.uid
    left join ta_post tpt on tps.poid=tpt.poid set tp.ptmid=tpt.ptmid;
-- <2016-03-10>更新物业参数，满二、满五、唯一，不允许修改
    UPDATE ta_reference SET flagallowmod='1', flagallowdel='1' WHERE (refid='402881eb494f534c01494f710ef50002');
    UPDATE ta_reference SET flagallowmod='1', flagallowdel='1' WHERE (refid='8a10a4224c6f9452014c72b2a8650e92');
    UPDATE ta_reference SET flagallowmod='1', flagallowdel='1' WHERE (refid='402881e647d96d9b0147d987eb150002');
** <2016-03-14>增加员工来源物业参数
    select refnamecn from ta_reference te where te.refid = '4aea439e3e1fd314013e20e6e0920007';
-- 如果结果是(组织机构)，执行下边的sql
    insert into ta_reference(refid,pid,refname,refnamecn,moddate,flagtrashed,flagdeleted,flagallowmod,flagallowdel)
    values('ecc56269-e9b2-11e5-94fa-687309d306a5','4aea439e3e1fd314013e20e6e0920007','empSource','员工来源',NOW(),'0','0','0','0');
    insert into ta_reference(refid,pid,refname,refnamecn,itemno,itemvalue,moddate,flagtrashed,flagdeleted,flagallowmod,flagallowdel)
    values('95741260-e988-11e5-94fa-687309d306a5','ecc56269-e9b2-11e5-94fa-687309d306a5','empSource','推荐人','01','推荐人',NOW(),'0','0','0','0');
    insert into ta_reference(refnamecn,itemvalue,refid,pid,refname,itemno,moddate,flagtrashed,flagdeleted,flagallowmod,flagallowdel)
    select temp.source,temp.source,UUID(),(select t.refid from ta_reference t where t.pid = '4aea439e3e1fd314013e20e6e0920007' and t.refname = 'empSource' and t.refnamecn = '员工来源')
    ,'empSource',(IF((@rownum:=@rownum+1) < 10,CONCAT(0,@rownum),@rownum)) as itemno,NOW(),'0','0','1','1'
    from(select DISTINCT te.source from ta_emplyee te
    where te.source is not null and te.source <> '' ) temp,(select @rownum:=1) num;
    update ta_emplyee join ta_reference on source = refnamecn and source = itemvalue and refname = 'empSource' set source = refid
    where source is not null and source <> '' and ta_reference.refname='empSource';
    alter table ta_emplyee add column refereeid varchar(40);
    alter table ta_emplyee add column refereeDeptid varchar(40);
-- 如果结果是(通用)，执行下边的sql
    insert into ta_reference(refid,pid,refname,refnamecn,moddate,flagtrashed,flagdeleted,flagallowmod,flagallowdel)
    values('ecc56269-e9b2-11e5-94fa-687309d306a5','586ff86e3f4c1d88013f5f52286e002a','empSource','员工来源',NOW(),'0','0','0','0');
    insert into ta_reference(refid,pid,refname,refnamecn,itemno,itemvalue,moddate,flagtrashed,flagdeleted,flagallowmod,flagallowdel)
    values('95741260-e988-11e5-94fa-687309d306a5','ecc56269-e9b2-11e5-94fa-687309d306a5','empSource','推荐人','01','推荐人',NOW(),'0','0','0','0');
    insert into ta_reference(refnamecn,itemvalue,refid,pid,refname,itemno,moddate,flagtrashed,flagdeleted,flagallowmod,flagallowdel)
    select temp.source,temp.source,UUID(),(select t.refid from ta_reference t where t.pid = '586ff86e3f4c1d88013f5f52286e002a' and t.refname = 'empSource' and t.refnamecn = '员工来源')
    ,'empSource',(IF((@rownum:=@rownum+1) < 10,CONCAT(0,@rownum),@rownum)) as itemno,NOW(),'0','0','1','1'
    from(select DISTINCT te.source from ta_emplyee te
    where te.source is not null and te.source <> '' ) temp,(select @rownum:=1) num;
    update ta_emplyee join ta_reference on source = refnamecn and source = itemvalue and refname = 'empSource' set source = refid
    where source is not null and source <> '' and ta_reference.refname='empSource';
    alter table ta_emplyee add column refereeid varchar(40);
    alter table ta_emplyee add column refereeDeptid varchar(40);
-- <2016-03-23>增加工作总结和工作日志的导出权限控制
    insert into ta_personauthority(uid,pauthorid,authcode,authcodevalue,isvalid,createdate)
    select DISTINCT t.uid,UUID(),'400305','1','5',NOW() from ta_personauthority t ;
    insert into ta_personauthority(uid,pauthorid,authcode,authcodevalue,isvalid,createdate)
    select DISTINCT t.uid,UUID(),'600306','1','5',NOW() from ta_personauthority t ;
    insert into ta_postauthority(ptmid,poauthid,authcode,authcodevalue,isvalid,createdate,modidate)
    select DISTINCT t.ptmid,UUID(),'400305','1','5',NOW(),NOW() from ta_postauthority t ;
    insert into ta_postauthority(ptmid,poauthid,authcode,authcodevalue,isvalid,createdate,modidate)
    select DISTINCT t.ptmid,UUID(),'600306','1','5',NOW(),NOW() from ta_postauthority t ;
-- <2016-03-25>物业管家，增加字段
    ALTER TABLE ta_modconf  ADD COLUMN modconfimage varchar(40);
    ALTER TABLE ta_systemuser  ADD COLUMN butlerstyle varchar(40);
-- <2016-03-28>选项设置增加“控制工作台业绩排行功能是否显示的选项”
    insert into ta_systemconfig(sysconfigid,syscode,syspcode,itemname,itemvalue,itemdesc,partcode,itemename) values('c46bc561-f48a-11e5-8928-00163e003a08','400446','4001','显示业绩排行','1','0','10','qita');
-- <2016-03-30>业绩分成表增加备注字段
    alter table ta_percentage add column remarks varchar(200);
-- <2016-04-05>增加选项“只有有效的房客源才能新增合同”
    insert into ta_systemconfig(sysconfigid,syscode,syspcode,itemname,itemvalue,itemdesc,partcode,itemename)
    values('902e4b11-facb-11e5-8928-00163e003a08','400447','4001','只有有效的房客源才能新增合同','0','0','10','qita');
-- <2016-04-08>系统用户表增加微信相关字段
    ALTER TABLE ta_systemuser ADD wxopenid VARCHAR(40);
-- <2016-04-13>选项设置增加云通讯服务商字段
    insert into ta_systemconfig values('1a76499b-014b-11e6-94fa-687309d306a5','100658','1006','云通讯服务商','1','0','10','fy');
-- <2016-04-13>鉴权回调表增加通讯服务商字段
    ALTER TABLE ta_callhangup ADD COLUMN servicetype varchar(40);
-- <2016-04-19>增加选项设置“显示无业绩的离职员工信息”
    insert into ta_systemconfig(sysconfigid,syscode,syspcode,itemname,itemvalue,itemdesc,partcode,itemename) values('3649cd14-05da-11e6-8928-00163e003a08','300224','3002','显示无业绩的离职员工信息','1','0','10','qita');
-- <2016-04-22>楼盘表增加描述字段
    alter table ta_estate add description varchar(2000);
-- <2016-04-27>新增的两张表ta_followcloud通讯跟进、ta_followcloud_his通讯跟进历史记录
    CREATE TABLE `ta_followcloud` (
      `followid` varchar(40) NOT NULL,  `houseid` varchar(40) NOT NULL,  `empid` varchar(40) NOT NULL,
      `deptid` varchar(40) DEFAULT NULL,  `followmethod` varchar(40) DEFAULT NULL,  `followdate` datetime DEFAULT NULL,
      `content` varchar(4000) DEFAULT NULL,  `remark` varchar(4000) DEFAULT NULL,  `flagdeleted` tinyint(1) DEFAULT NULL,
      `flagtrashed` tinyint(1) DEFAULT NULL,  `createdate` datetime DEFAULT NULL,  `moddate` datetime DEFAULT NULL,
      `deldate` datetime DEFAULT NULL,  PRIMARY KEY (`followid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    CREATE TABLE `ta_followcloud_his` (
      `followid` varchar(40) NOT NULL,  `houseid` varchar(40) NOT NULL,  `empid` varchar(40) NOT NULL,
      `deptid` varchar(40) DEFAULT NULL,  `followmethod` varchar(40) DEFAULT NULL,  `followdate` datetime DEFAULT NULL,
      `content` varchar(4000) DEFAULT NULL,  `remark` varchar(4000) DEFAULT NULL,  `flagdeleted` tinyint(1) DEFAULT NULL,
      `flagtrashed` tinyint(1) DEFAULT NULL,  `createdate` datetime DEFAULT NULL,  `moddate` datetime DEFAULT NULL,
      `deldate` datetime DEFAULT NULL,  PRIMARY KEY (`followid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- <2016-05-16>新增微信分享表ta_wxshare
    CREATE TABLE `ta_wxshare` (
      `shareid` varchar(40) NOT NULL,
      `belongid` varchar(40) DEFAULT NULL,
      `openid` varchar(40) DEFAULT NULL,
      `empid` varchar(40) DEFAULT NULL,
      `sharetime` datetime DEFAULT NULL,
      PRIMARY KEY (`shareid`)
    );
-- <2016-05-19>微信增加字段
    ALTER TABLE ta_company ADD wxtemplateid VARCHAR(80);
-- <2016-05-23>增加字段，处理数据
    -- 公司表增加电信appid、ims、key字段
    ALTER TABLE ta_company  ADD COLUMN caasappid varchar(40);
    ALTER TABLE ta_company  ADD COLUMN caasims varchar(40);
    ALTER TABLE ta_company  ADD COLUMN caaskey varchar(40);
    -- 核心系统处理未写跟进数据
    update ta_followsys set flagviewowner=2 where flagviewowner=1 or flagviewowner is null;
-- <2016-05-30>增加表福建电信云通讯表
    CREATE TABLE `ta_caasno` (
      `caasnoid` varchar(40) NOT NULL,
      `ims` varchar(40) DEFAULT NULL,
      `key` varchar(40) DEFAULT NULL,
      `code` int(11) DEFAULT NULL,
      `stopflag` tinyint(1) DEFAULT NULL,
      PRIMARY KEY (`caasnoid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- <2016-05-31>云通讯数据处理
    -- 云通讯客户录音文件需要转码（详见《云通讯转码》文档）
    ALTER TABLE ta_followcloud ADD COLUMN callsid VARCHAR (40);
    ALTER TABLE ta_followcloud_his ADD COLUMN callsid VARCHAR (40);
    UPDATE ta_followcloud SET callsid = REPLACE (remark, '已下载', '');
    UPDATE ta_followcloud  SET flagtrashed= 1 WHERE  remark not LIKE '已下载%';
-- <2016-06-22>增加选项，业主重复不允许保存
    INSERT INTO `ta_systemconfig` VALUES ('12c851cf-377f-11e6-94fa-687309d306a5', '101006', '101006', '业主重复不允许保存', '0', '0', '10', 'fangyuan10001');
-- <2016-07-19>设置管理员的入职日期
    update ta_emplyee set joindate='2000-01-01 00:00:00' where empid='1461d2f6-863d-11e2-9649-00163e020d5e';
-- <2016-08-02>更新资料房源数据
    update ta_propertydata set dateno=replace(dateno,'-','');
-- <2016-08-10>更新诚意金的部门id
    update ta_honest tho left join ta_emplyee tee on tho.empid=tee.empid  set tho.empdepid=tee.deptid where tho.empdepid<>tee.deptid;
-- <2016-08-11>增加选项设置
    INSERT INTO ta_systemconfig( sysconfigid, syscode, syspcode, itemname, itemvalue, itemdesc, partcode, itemename) VALUES ( 'a22445a3-5f88-11e6-8928-00163e003a08', '300225', '3002', ' 流程查看权限按照分成人来判断', '0', '0', '10', 'hetong300225' );
-- <2016-09-02>增加图片压缩选项
    INSERT INTO ta_systemconfig (sysconfigid, syscode, syspcode, itemname, itemvalue, itemdesc, partcode, itemename) VALUES ('31f83010-6f32-11e6-add2-c0aa135fa213', '400137', '4001', '上传图片启用压缩功能', '1', '0', '10', 'qita1037');
-- <2016-09-08>产权过户表增加字段是否资金监管
    ALTER TABLE ta_transfercommission  ADD COLUMN supervise tinyint(1);
-- <2016-09-21>工作日志增加字段
    alter table ta_worklogdetail add COLUMN postflag VARCHAR(40);
    alter table ta_dailyworkload add INDEX `idx_dal_detailid` (`worklogdetailid`);
    update  ta_worklogdetail tw left join ta_dailyworkload td on tw.worklogdetailid=td.worklogdetailid
    set tw.postflag=1 where td.validhousesell is null;
    update  ta_worklogdetail tw left join ta_dailyworkload td on tw.worklogdetailid=td.worklogdetailid
    set tw.postflag=2 where td.validhousesell is not null;
-- <2016-09-28>修改物业参数状态
    update ta_reference set flagallowmod='-1' where refid='402881ed4738b1bb014738c4f0050004';
-- <2016-10-18>增加个人中心权限
    delete from ta_personauthority where authcode='5014';
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate)
    select UUID(),uid,'5014','1','6',NOW() from ta_personauthority where authcode='100101';
-- <2016-10-19>自动转房客，封盘转公/私盘增加结盘日期
    alter table ta_house add COLUMN finisheddate datetime;
-- <2016-10-21>增加双签约人
    INSERT INTO `ta_systemconfig` VALUES ('05e224fd-95ca-11e6-833b-089bf2ebc20a', '300226', '3002', '中介合同启用双签约人', '0', '0', '10', 'hetong300226');
    alter table ta_contractinfo add COLUMN deptidtwo VARCHAR(40);
    alter table ta_contractinfo add COLUMN empidtwo VARCHAR(40);
-- <2016-10-26>交易明细报表
    UPDATE ta_reporttitle SET titlesn =  titlesn+2 WHERE rtplid = '402881e64a95768b014a957dc2210001' AND titlesn > 4;
    INSERT INTO ta_reporttitle VALUES(UUID(),'402881e64a95768b014a957dc2210001','paycommissiondate','结佣日期',5,'string',null,1,1,1,82,1,1,null);
    INSERT INTO ta_reporttitle VALUES(UUID(),'402881e64a95768b014a957dc2210001','finisheddate','结盘日期',6,'string',null,1,1,1,82,1,1,null);
-- <2016-11-05>求租求购分开查重
    INSERT INTO `ta_systemconfig` VALUES ('50cc1fed-a09d-11e6-8706-1df26a3ae3c4', '200407', '2004', '求租求购分开查重', '0', '0', '10', 'keyuan4007');
-- <2016-11-10>客源云通讯
    INSERT INTO `ta_systemconfig` VALUES ('9f04ace2-a4b0-11e6-8706-1df26a3ae3c4', '200601', '2006', '客源启用云通讯', '0', '0', '10', 'keyuan2006');
    CREATE TABLE `ta_inqfollowcloud` (
      `followid` varchar(40) NOT NULL,
      `inquiryid` varchar(40) NOT NULL,
      `empid` varchar(40) NOT NULL,
      `deptid` varchar(40) DEFAULT NULL,
      `followmethod` varchar(40) DEFAULT NULL,
      `followdate` datetime DEFAULT NULL,
      `content` varchar(4000) DEFAULT NULL,
      `remark` varchar(4000) DEFAULT NULL,
      `flagdeleted` tinyint(1) DEFAULT NULL,
      `flagtrashed` tinyint(1) DEFAULT NULL,
      `createdate` datetime DEFAULT NULL,
      `moddate` datetime DEFAULT NULL,
      `deldate` datetime DEFAULT NULL,
      `callsid` varchar(40) DEFAULT NULL,
      PRIMARY KEY (`followid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    CREATE TABLE `ta_inqfollowcloud_his` (
      `followid` varchar(40) NOT NULL,
      `inquiryid` varchar(40) NOT NULL,
      `empid` varchar(40) NOT NULL,
      `deptid` varchar(40) DEFAULT NULL,
      `followmethod` varchar(40) DEFAULT NULL,
      `followdate` datetime DEFAULT NULL,
      `content` varchar(4000) DEFAULT NULL,
      `remark` varchar(4000) DEFAULT NULL,
      `flagdeleted` tinyint(1) DEFAULT NULL,
      `flagtrashed` tinyint(1) DEFAULT NULL,
      `createdate` datetime DEFAULT NULL,
      `moddate` datetime DEFAULT NULL,
      `deldate` datetime DEFAULT NULL,
      `callsid` varchar(40) DEFAULT NULL,
      PRIMARY KEY (`followid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- <2016-12-16>房源证件类型必填
    INSERT INTO ta_systemconfig VALUES('cec1aca8-c34d-11e6-9279-41d258413e73',100216,1002,'房源(证件类型)必填',0,0,10,'fangyuan2016');
-- <2017-02-21>增加短信模板相关字段
    alter table ta_flowpathstepdetailsdatabase add  column ownersmsmouldid VARCHAR(40);-- 完成发业主短信内容模板ID
    alter table ta_flowpathstepdetailsdatabase add  column cussmsmouldid VARCHAR(40);-- 完成发客户短信内容模板ID
-- <2017-02-28>员工变动记录表增加字段原岗位id、新岗位id
    ALTER TABLE ta_empfollow ADD COLUMN oldptmid varchar (40);
    ALTER TABLE ta_empfollow ADD COLUMN newptmid varchar (40);
-- <2017-03-24>手机改版行程表
    DROP TABLE IF EXISTS `ta_trip`;
    CREATE TABLE `ta_trip` (
      `tripid` varchar(40) NOT NULL,
      `inquiryid` varchar(40) DEFAULT NULL,
      `estateid` varchar(40) DEFAULT NULL,
      `houseid` varchar(400) DEFAULT NULL,
      `tripdate` datetime DEFAULT NULL,
      `triptype` varchar(40) DEFAULT NULL,
      `empid` varchar(40) DEFAULT NULL,
      `content` varchar(400) DEFAULT NULL,
      `longitude` varchar(40) DEFAULT NULL,
      `latitude` varchar(40) DEFAULT NULL,
      `location` varchar(64) DEFAULT NULL,
      PRIMARY KEY (`tripid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- <2017-03-24>手机端打卡位置字段
    alter table `ta_clockrecord` add  `longitude` varchar(40) ;
    alter table `ta_clockrecord` add  `latitude` varchar(40) ;
    alter table `ta_clockrecord` add  `location` varchar(64) ;
-- <2017-03-24>手机端打卡类型
    alter table `ta_clockrecord` add  `clocktype` int ;
-- <2017-04-10>公司简介放开
    alter table ta_company modify briefintroduction text;
-- <2017-04-27>房源〔委托编号〕必填
    INSERT INTO `ta_systemconfig` VALUES ('72fc511d-2b10-11e7-a85d-9f5df2a9785c', '100217', '1002', '房源〔委托编号〕必填', '1', '0', '10', 'fangyuan2017');
-- <2017-05-25>房源增加委托标识字段
    ALTER table ta_house add COLUMN flagtrust TINYINT(1);
-- <2017-05-27>增加优质客设定日期
    alter table ta_inquiry add COLUMN qualitytime datetime;
-- <2017-05-31>更新借钥匙次数
    UPDATE ta_housekey thr LEFT JOIN ( SELECT thk.housekeyid, count(*) countNum FROM ta_keyrecord thk GROUP BY thk.housekeyid ) t
    ON thr.housekeyid = t.housekeyid SET thr.borrowviews = IFNULL(t.countNum, 0);
-- <2017-06-20>顺益兴联行定制导出功能
    -- 只是北京顺益兴联行执行
    -- INSERT INTO `ta_systemconfig` VALUES ('c85ae05c-5580-11e7-a8d7-99075598f710', '608001', '6080', '导出房客源', '0', '0', '10', 'qita6080');
-- <2017-07-04>更新没有设置过考勤备注权限的人为“无”
    INSERT INTO ta_personauthority (pauthorid,uid,authcode,authcodevalue,isvalid,createdate,modidate)
    (SELECT uuid(),s.uid,'400824','1','5','2017-07-05',NULL FROM ta_systemuser s WHERE s.uid not in
    (SELECT uid FROM ta_personauthority WHERE authcode = '400824'));
-- <2017-07-12>合同跟进增加字段[提醒内容]的长度
    ALTER TABLE ta_conupdate MODIFY COLUMN remindcontent VARCHAR(1000);
-- <2017-08-25>私客电话查看 同 私客列表查看权限一致
    insert into ta_personauthority(pauthorid,uid,authcode,authcodevalue,isvalid,createdate)
    select UUID(),uid,'200808',authcodevalue,'2',NOW() from ta_personauthority where authcode='200106';
-- <2017-09-01>给合同房客源归属部门店长、流程总负责人发短信
    alter table ta_contractinfo add COLUMN housedeptid VARCHAR(40);
    alter table ta_contractinfo add COLUMN inquirydeptid VARCHAR(40);
    alter table ta_flowpathstepdetailsdatabase add COLUMN flagsenddept TINYINT(1);
    alter table ta_flowpathstepdetailsdatabase add COLUMN senddeptcontent varchar(200);
    alter table ta_flowpathstepdetailsdatabase add COLUMN deptsmsmouldid varchar(40);
    alter table ta_flowpathstepdetailsdatabase add COLUMN flagsendmanage TINYINT(1);
    alter table ta_flowpathstepdetailsdatabase add COLUMN sendmanagecontent varchar(200);
    alter table ta_flowpathstepdetailsdatabase add COLUMN managesmsmouldid varchar(40);
-- <2017-09-04>增加发布到外网日期
    alter TABLE ta_house add COLUMN outsidedate datetime;
-- <2017-09-08>增加配置多个微信功能
    ALTER TABLE ta_area add COLUMN wxappid VARCHAR(40);
    ALTER TABLE ta_area add COLUMN wxappsecret VARCHAR(40);
    ALTER TABLE ta_area add COLUMN wxtemplateid VARCHAR(80);
-- <2017-10-10>批量修改记录
    CREATE TABLE `ta_followupdate` (
      `followupdateid` varchar(40) NOT NULL DEFAULT '',
      `inquiryid` varchar(40) DEFAULT NULL,
      `updatesource` varchar(40) DEFAULT NULL,
      `createtime` datetime DEFAULT NULL,
      `createempid` varchar(40) DEFAULT NULL,
      `flagupdate` tinyint(1) DEFAULT NULL,
      `empid` varchar(40) DEFAULT NULL,
      PRIMARY KEY (`followupdateid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- <2017-10-20>CRM,PLAT域名存数据库
    ALTER table ta_company add COLUMN crmurl VARCHAR(40);
    ALTER table ta_company add COLUMN platurl VARCHAR(40);
    update ta_company set crmurl='http://crm.fangyitongsoft.com',platurl='http://plat.hzlysoft.com';
-- <2017-11-09>增加主力户型
    ALTER TABLE ta_estate  ADD COLUMN mainforce varchar(40);
-- <2017-12-22>营销中心
    CREATE TABLE ta_browserecord(
        browserecordid    VARCHAR(40)    NOT NULL,
        houseid           VARCHAR(40),
        platformid        VARCHAR(40),
        browsetime        DATE,
        browse            INT,
        PRIMARY KEY (browserecordid)
    )ENGINE=INNODB;
    CREATE TABLE ta_cityrelationship(
        cityrelationshipid    VARCHAR(40)    NOT NULL,
        oldcityid             VARCHAR(40),
        newcityid             VARCHAR(40),
        PRIMARY KEY (cityrelationshipid)
    )ENGINE=INNODB;
    CREATE TABLE ta_dsrelationship(
        dsrelationshipid    VARCHAR(40)    NOT NULL,
        olddsid             VARCHAR(40),
        newdsid             VARCHAR(40),
        PRIMARY KEY (dsrelationshipid)
    )ENGINE=INNODB;
    CREATE TABLE ta_empplatform(
        empplatformid    VARCHAR(40)    NOT NULL,
        empid            VARCHAR(40),
        platformid       VARCHAR(40)    NOT NULL,
        opentime         DATETIME,
        status           INT,
        PRIMARY KEY (empplatformid)
    )ENGINE=INNODB;
    CREATE TABLE ta_estaterelationship(
        estaterelationshipid    VARCHAR(40)    NOT NULL,
        estid                   VARCHAR(40),
        companyestid            VARCHAR(40),
        PRIMARY KEY (estaterelationshipid)
    )ENGINE=INNODB;
    CREATE TABLE ta_houseplatform(
        houseplatformid    VARCHAR(40)    NOT NULL,
        houseid            VARCHAR(40)    NOT NULL,
        platformid         VARCHAR(40)    NOT NULL,
        releasetime        DATETIME,
        renewtime          DATETIME,
        browse             INT,
        status             INT,
        PRIMARY KEY (houseplatformid)
    )ENGINE=INNODB;
    CREATE TABLE ta_label(
        labelid       VARCHAR(40)    NOT NULL,
        name          VARCHAR(40),
        regtime       DATETIME,
        systemflag    TINYINT,
        PRIMARY KEY (labelid)
    )ENGINE=INNODB;
    CREATE TABLE ta_managerange(
        managerangeid    VARCHAR(40)    NOT NULL,
        empid            VARCHAR(40),
        deptid           VARCHAR(40),
        PRIMARY KEY (managerangeid)
    )ENGINE=INNODB;
    CREATE TABLE ta_otherrule(
        otherruleid    VARCHAR(40)    NOT NULL,
        name           VARCHAR(40),
        code           VARCHAR(40),
        value          TINYINT,
        PRIMARY KEY (otherruleid)
    )ENGINE=INNODB;
    CREATE TABLE ta_platform(
        platformid      VARCHAR(40)     NOT NULL,
        platformname    VARCHAR(40),
        platformlogo    VARCHAR(40),
        startflag       INT,
        sort            INT,
        summary         VARCHAR(200),
        url             VARCHAR(40),
        PRIMARY KEY (platformid)
    )ENGINE=INNODB;
    CREATE TABLE ta_receivelog(
        receivelogid    VARCHAR(40)     NOT NULL,
        receivetype     VARCHAR(40),
        belongid        VARCHAR(40),
        result          INT,
        message         VARCHAR(200),
        date            DATETIME,
        batchno         VARCHAR(40),
        PRIMARY KEY (receivelogid)
    )ENGINE=INNODB;
    CREATE TABLE ta_rulelabel(
        rulelabelid    VARCHAR(40)    NOT NULL,
        titleruleid    VARCHAR(40)    NOT NULL,
        labelid        VARCHAR(40),
        sort           INT,
        PRIMARY KEY (rulelabelid)
    )ENGINE=INNODB;
    CREATE TABLE ta_sendlog(
        sendlogid    VARCHAR(40)     NOT NULL,
        sendtype     VARCHAR(40),
        belongid     VARCHAR(40),
        result       INT,
        message      VARCHAR(200),
        date         DATETIME,
        batchno      VARCHAR(40),
        PRIMARY KEY (sendlogid)
    )ENGINE=INNODB;
    CREATE TABLE ta_titlerule(
        titleruleid    VARCHAR(40)    NOT NULL,
        type           INT,
        effectrange    VARCHAR(40),
        regtime        DATETIME,
        status         TINYINT,
        flagtrashed    TINYINT,
        PRIMARY KEY (titleruleid)
    )ENGINE=INNODB;
-- <2017-12-22>员工增加是否为运维人员字段
    alter table ta_emplyee add column maintenance tinyint(1);
-- <2017-12-23>房源平台关系表增加推广人字段
    alter table ta_houseplatform add column empid varchar(40);
-- <2017-12-23>增加推广异常数据表
    CREATE TABLE ta_abnormal(
        abnormalid    VARCHAR(40)    NOT NULL,
        houseid       VARCHAR(40),
        platformid    VARCHAR(40),
        date          DATETIME,
        PRIMARY KEY (abnormalid)
    )ENGINE=INNODB;
-- <2018-01-15>保留原图
    alter table ta_attachment add column bigurl varchar(200);
    update ta_attachment set bigurl=attachurl;
-- <2018-1-16>员工平台关系表增加平台用户名、密码、用户id字段
    alter table ta_empplatform add column username varchar(40);
    alter table ta_empplatform add column password varchar(40);
    alter table ta_empplatform add column userid varchar(40);
-- <2018-1-16>平台表增加平台明文id、平台密文字段
    alter table ta_platform add column companyid varchar(40);
    alter table ta_platform add column ciphertext varchar(40);
-- <2018-1-18>公司表增加搜房接口地址字段
    alter table ta_company add column sfurl varchar(200);
-- <2018-1-25>房源平台关系表增加外部id字段
    alter table ta_houseplatform add column outsideid varchar(40);
-- <2018-1-25>增加图片关系表
    CREATE TABLE ta_photorelationship(
        photorelationshipid    VARCHAR(40)     NOT NULL,
        attaid                 VARCHAR(40),
        outsideurl             VARCHAR(200),
        platformid             VARCHAR(40),
        houseid                VARCHAR(40),
        PRIMARY KEY (photorelationshipid)
    )ENGINE=INNODB;
-- <2018-1-26>图片关系表增加外部图片id字段
    alter table ta_photorelationship add column outsideid varchar(40);
-- <2018-01-31>只是河南豫港执行，需要重启 memcached
    -- INSERT INTO `ta_reference` (`refid`, `pid`, `refname`, `refnamecn`, `itemno`, `itemvalue`, `iteminfo`, `moddate`, `flagtrashed`, `flagdeleted`, `flagallowmod`, `flagallowdel`) VALUES ('8a9f648d6149b80201614a391c2b0c2f', '4aea439e3e1fd314013e21152c5e00bb', 'InquiryTrust', 'D-新房客', '04', 'D-新房客', '', '2018-1-31 11:18:32', '0', '0', '0', '0');
-- <2018-01-31>增加分成规则
    CREATE TABLE `ta_percentagerule` (
      `percentageruleid` varchar(40) NOT NULL,
      `tradetype` varchar(40) DEFAULT NULL,
      `belongsource` varchar(40) DEFAULT NULL,
      `reason` varchar(40) DEFAULT NULL,
      `proportions` decimal(20,2) DEFAULT NULL,
      `percentageexplain` varchar(40) DEFAULT NULL,
      `regperson` varchar(40) DEFAULT NULL,
      `regdate` datetime DEFAULT NULL,
      PRIMARY KEY (`percentageruleid`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- <2018-01-31>增加选项
    INSERT INTO `ta_systemconfig` VALUES('8b4be3b6-059d-11e8-912e-965e17556704','300227','3002','合同录入后自动生成应收业绩',0,0,10,'hetong300227');
    INSERT INTO `ta_systemconfig` VALUES('c2e2205d-059d-11e8-912e-965e17556704','300228','3002','出租合同应收业绩百分比',0,0,10,'hetong300228');
    INSERT INTO `ta_systemconfig` VALUES('c2e3c012-059d-11e8-912e-965e17556704','300229','3002','出售合同应收业绩百分比',0,0,10,'hetong300229');
    INSERT INTO `ta_systemconfig` VALUES('4e5e6b98-0685-11e8-912e-965e17556704','300230','3002','个月',0,0,10,'hetong300230');
    alter table ta_receivablepayable add regsystem VARCHAR(40);
-- <2018-02-28>增加房源审批规则选项
    INSERT into ta_systemconfig VALUES('c8d397d5-1be0-11e8-a44a-a73618d6eb14','100659','1006','房源审批规则','0','0','10','fyshp');
-- <2018-03-20>系统用户增加通讯小号字段
    ALTER TABLE ta_systemuser add column platphone VARCHAR(40);
-- <2018-03-20>修改mfk3 鉴权表中 录音路径 字段长度
    alter table ta_callhangup  modify column recordurl varchar(800);
-- <2018-03-26>托管合同增加总金额
    ALTER table  ta_trusteeshipcontract  ADD COLUMN totalrent decimal(20);
    update ta_trusteeshipcontract set totalrent=(monthrent*trustdeadline);
-- <2018-04-02>depositsource 存入来源
    ALTER table ta_house  ADD COLUMN depositsource VARCHAR(200);
    ALTER table ta_inquiry  ADD COLUMN depositsource VARCHAR(200);
-- <2018-04-02>业绩分成规则维护
    INSERT INTO ta_authorityitem (`authorid`, `authcode`, `pauthcode`, `authcname`, `authename`, `authdesc`, `effectpoint`, `isvalid`, `createdate`, `modidatae`) VALUES ('14038909-3686-11e8-a568-a5ac6e256eb9', '30011111', '300111', '业绩分成规则维护', NULL, NULL, NULL, '1', '2018-4-2', NULL);
-- <2018-05-25>新的需求为了区别物业用途为写字楼，添加两个字段公司名称，营业执照
    ALTER TABLE ta_contractinfo  ADD COLUMN  corporatename VARCHAR(40);
    ALTER TABLE ta_contractinfo  ADD COLUMN  businesslicense VARCHAR(40);
-- <2018-06-04>信息阅读记录表里面，添加一个字段已读标识
    ALTER TABLE ta_inforeadrecord  ADD COLUMN  flagread tinyint(1)  DEFAULT  '1';