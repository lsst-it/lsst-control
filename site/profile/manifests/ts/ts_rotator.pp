class profile::ts::ts_rotator{
	include ts_sal
	
	class{"ts_xml":
		ts_xml_path => lookup("ts_xml::ts_xml_path"),
		ts_xml_subsystems => lookup("ts::ts_dome::ts_xml_subsystems"),
		ts_xml_languages => lookup("ts::ts_dome::ts_xml_languages"),
		ts_sal_path => lookup("ts_sal::ts_sal_path"),
	}
}