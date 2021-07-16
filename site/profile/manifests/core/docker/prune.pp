# @summary
#   Enable periodic cleanup of unused docker resources
#
class profile::core::docker::prune {
  cron::job { 'docker_prune':
    minute      => '00',
    hour        => '16',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    command     => 'systemd-cat -t docker-prune docker system prune -a --filter "until=$((90*24))h" --force'
    environment => [ 'PATH="/bin"' ],
    description => 'Run docker system rpune',
  }
}
