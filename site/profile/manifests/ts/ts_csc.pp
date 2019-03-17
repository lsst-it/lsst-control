# Generic CSC, configuration comes from hiera
class profile::ts::ts_csc{
  include ts_sal
  include ts_xml
}
