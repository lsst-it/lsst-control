lsst-itconf
===

* ![markdownlint](https://github.com/lsst-it/lsst-itconf/actions/workflows/markdownlint.yaml/badge.svg)
* ![rake checks](https://github.com/lsst-it/lsst-itconf/actions/workflows/rake_checks.yaml/badge.svg)
* ![shellcheck](https://github.com/lsst-it/lsst-itconf/actions/workflows/shellcheck.yaml/badge.svg)
* ![yamllint](https://github.com/lsst-it/lsst-itconf/actions/workflows/yamllint.yaml/badge.svg)

Hiera Layers
------------

Direct inclusion of classes via hiera is allowed but, by convention, restricted
to `role` layers.

| Layer                                                                   | Class Inclusion Allowed |
| -----                                                                   | ----------------------- |
| node/%{fqdn}.yaml                                                       | no                      |
| site/%{site}/cluster/%{cluster}/role/%{role}.yaml                       | yes                     |
| site/%{site}/cluster/%{cluster}.yaml                                    | no                      |
| cluster/%{cluster}/role/%{role}.yaml                                    | yes                     |
| cluster/%{cluster}/osfamily/%{os.family}/major/%{os.release.major}.yaml | no                      |
| cluster/%{cluster}.yaml                                                 | no                      |
| site/%{site}/role/%{role}.yaml                                          | yes                     |
| site/%{site}.yaml                                                       | no                      |
| role/%{role}/osfamily/%{os.family}/major/%{os.release.major}.yaml       | yes                     |
| role/%{role}.yaml                                                       | yes                     |
| common/osfamily/%{os.family}/major/%{os.release.major}.yaml             | no                      |
| common.yaml                                                             | no                      |
