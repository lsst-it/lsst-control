lsst-control
===

* ![markdownlint](https://github.com/lsst-it/lsst-control/actions/workflows/markdownlint.yaml/badge.svg)
* ![rake checks](https://github.com/lsst-it/lsst-control/actions/workflows/rake_checks.yaml/badge.svg)
* ![shellcheck](https://github.com/lsst-it/lsst-control/actions/workflows/shellcheck.yaml/badge.svg)
* ![yamllint](https://github.com/lsst-it/lsst-control/actions/workflows/yamllint.yaml/badge.svg)

This is the primary Rubin Observatory [puppet control
repo](https://github.com/puppetlabs/control-repo) for the Summit, Base Data
Center, and Tucson Teststand.

Hiera Layers
------------

Direct inclusion of classes via hiera is allowed but, by convention, restricted
to `role` layers.

| Layer                                                                   | Class Inclusion Allowed |
| -----                                                                   | ----------------------- |
| node/%{fqdn}.yaml                                                       | no                      |
| site/%{site}/cluster/%{cluster}/role/%{role}.yaml                       | yes                     |
| site/%{site}/cluster/%{cluster}.yaml                                    | no                      |
| cluster/%{cluster}/variant/%{variant}/%{os.family}/major/%{os.release.major}.yaml | no            |
| cluster/%{cluster}/variant/%{variant}.yaml                              | no                      |
| cluster/%{cluster}/role/%{role}.yaml                                    | yes                     |
| cluster/%{cluster}/osfamily/%{os.family}/major/%{os.release.major}.yaml | no                      |
| cluster/%{cluster}.yaml                                                 | no                      |
| site/%{site}/role/%{role}.yaml                                          | yes                     |
| site/%{site}.yaml                                                       | no                      |
| role/%{role}/osfamily/%{os.family}/major/%{os.release.major}.yaml       | yes                     |
| role/%{role}.yaml                                                       | yes                     |
| common/osfamily/%{os.family}/major/%{os.release.major}.yaml             | no                      |
| common.yaml                                                             | no                      |
