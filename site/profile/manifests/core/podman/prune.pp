# @summary
#   Enable periodic cleanup of unused podman resources
#
class profile::core::podman::prune {
  cron::job { 'podman_prune':
    minute      => '0',
    hour        => '16',
    date        => '*',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    command     => 'systemd-cat -t podman-prune podman system prune -a --filter "until=$((14*24))h" --force',
    environment => ['PATH="/bin"'],
    description => 'Run podman system prune',
  }
}
