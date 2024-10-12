{
  config,
  pkgs,
  lib,
  ...
}:
let

  promUid = "victoriametrics";
in
{

  config = lib.mkIf config.services.grafana.enable {

    # Allow Grafana to connect to email service
    secrets.mailpass-grafana = {
      source = ../../../private/mailpass-grafana.age;
      dest = "${config.secretsDirectory}/mailpass-grafana";
      owner = "grafana";
      group = "grafana";
      permissions = "0440";
    };
    systemd.services.mailpass-grafana-secret = {
      requiredBy = [ "grafana.service" ];
      before = [ "grafana.service" ];
    };

    services.grafana = {
      settings = {
        server = {
          domain = config.hostnames.metrics;
          http_addr = "127.0.0.1";
          http_port = 3000;
          protocol = "http";
        };
        smtp = rec {
          enabled = true;
          host = "${config.mail.smtpHost}:465";
          user = "grafana@${config.mail.server}";
          password = "$__file{${config.secrets.mailpass-grafana.dest}}";
          from_name = "Grafana";
          from_address = user;
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "VictoriaMetrics";
            type = "prometheus";
            access = "proxy";
            url = "http://localhost${config.services.victoriametrics.listenAddress}";
            uid = promUid;
          }
        ];
        # TODO: Add option to pull services from a list like Caddy does
        dashboards.settings.providers = [
          {
            name = "test";
            type = "file";
            allowUiUpdates = true;
            options.path = "${
              (pkgs.writeTextDir "dashboards/dashboard.json" (
                builtins.toJSON {
                  annotations = {
                    list = [
                      {
                        builtIn = 1;
                        datasource = {
                          type = "grafana";
                          uid = "-- Grafana --";
                        };
                        enable = true;
                        hide = true;
                        iconColor = "rgba(0, 211, 255, 1)";
                        name = "Annotations & Alerts";
                        target = {
                          limit = 100;
                          matchAny = false;
                          tags = [ ];
                          type = "dashboard";
                        };
                        type = "dashboard";
                      }
                    ];
                  };
                  editable = true;
                  fiscalYearStartMonth = 0;
                  graphTooltip = 0;
                  id = 1;
                  links = [ ];
                  liveNow = false;
                  panels = [
                    {
                      collapsed = false;
                      gridPos = {
                        h = 1;
                        w = 24;
                        x = 0;
                        y = 0;
                      };
                      id = 20;
                      panels = [ ];
                      title = "Services";
                      type = "row";
                    }

                    # Uptime (Overall)
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          decimals = 2;
                          mappings = [ ];
                          max = 1;
                          min = 0;
                          noValue = "0";
                          thresholds = {
                            mode = "percentage";
                            steps = [
                              {
                                color = "#9d2a37";
                                value = null;
                              }
                              {
                                color = "#a8663a";
                                value = 99;
                              }
                              {
                                color = "#bea25c";
                                value = 99.8;
                              }
                              {
                                color = "#62895d";
                                value = 100;
                              }
                            ];
                          };
                          unit = "percentunit";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 4;
                        w = 3;
                        x = 0;
                        y = 1;
                      };
                      id = 146;
                      options = {
                        colorMode = "background";
                        graphMode = "area";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        text = { };
                        textMode = "value_and_name";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "min(avg_over_time(up))";
                          instant = false;
                          legendFormat = "Min";
                          range = true;
                          refId = "A";
                        }
                      ];
                      title = "Uptime";
                      type = "stat";
                    }

                    # Cloudflare Tunnel
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          decimals = 2;
                          mappings = [ ];
                          max = 1;
                          min = 0;
                          noValue = "0";
                          thresholds = {
                            mode = "percentage";
                            steps = [
                              {
                                color = "#720d19";
                                value = null;
                              }
                              {
                                color = "#a8663a";
                                value = 99;
                              }
                              {
                                color = "semi-dark-orange";
                                value = 100;
                              }
                            ];
                          };
                          unit = "percentunit";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 4;
                        w = 4;
                        x = 3;
                        y = 1;
                      };
                      id = 157;
                      options = {
                        colorMode = "background";
                        graphMode = "area";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        text = { };
                        textMode = "value_and_name";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = ''systemd_unit_state{name=~"cloudflared-tunnel-.*", state="active"}'';
                          instant = false;
                          legendFormat = "{{job}}";
                          range = true;
                          refId = "A";
                        }
                      ];
                      title = "Tunnel";
                      type = "stat";
                    }

                    # Services Uptime
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          mappings = [
                            {
                              options = {
                                "0" = {
                                  color = "dark-red";
                                  index = 1;
                                  text = "Down";
                                };
                                "1" = {
                                  color = "#305387";
                                  index = 0;
                                  text = "Up";
                                };
                              };
                              type = "value";
                            }
                          ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "green";
                                value = null;
                              }
                              {
                                color = "red";
                                value = 80;
                              }
                            ];
                          };
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 4;
                        w = 6;
                        x = 7;
                        y = 1;
                      };
                      id = 13;
                      links = [ ];
                      options = {
                        colorMode = "background";
                        graphMode = "none";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        textMode = "auto";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "nextcloud_up";
                          instant = false;
                          interval = "";
                          legendFormat = "Nextcloud";
                          range = true;
                          refId = "A";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = "sabnzbd_status";
                          hide = false;
                          legendFormat = "Sabnzbd";
                          range = true;
                          refId = "B";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = "radarr_system_status";
                          hide = false;
                          legendFormat = "Radarr";
                          range = true;
                          refId = "C";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = "readarr_system_status";
                          hide = false;
                          legendFormat = "Readarr";
                          range = true;
                          refId = "F";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = "sonarr_system_status";
                          hide = false;
                          legendFormat = "Sonarr";
                          range = true;
                          refId = "D";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = "prowlarr_system_status";
                          hide = false;
                          legendFormat = "Prowlarr";
                          range = true;
                          refId = "E";
                        }
                      ];
                      title = "Services";
                      transparent = true;
                      type = "stat";
                    }

                    # Gitea Actions (disabled?)
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "#5d664a";
                                value = null;
                              }
                            ];
                          };
                          unit = "none";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 4;
                        w = 3;
                        x = 13;
                        y = 1;
                      };
                      id = 90;
                      links = [
                        {
                          targetBlank = true;
                          title = "";
                          url = "https://${config.hostnames.git}/admin/runners";
                        }
                      ];
                      options = {
                        colorMode = "background";
                        graphMode = "none";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        textMode = "auto";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = ''gitea_actions{job="flame"}'';
                          instant = false;
                          interval = "";
                          legendFormat = "__auto";
                          range = true;
                          refId = "A";
                        }
                      ];
                      title = "Gitea Actions";
                      transparent = true;
                      type = "stat";
                    }

                    # Video Library
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            fixedColor = "#5a4c30";
                            mode = "fixed";
                          };
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "dark-blue";
                                value = null;
                              }
                            ];
                          };
                          unit = "bytes";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 4;
                        w = 3;
                        x = 16;
                        y = 1;
                      };
                      id = 18;
                      links = [
                        {
                          targetBlank = true;
                          title = "";
                          url = "https://${config.hostnames.stream}";
                        }
                      ];
                      options = {
                        colorMode = "background";
                        graphMode = "none";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        textMode = "auto";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          "expr" = ''zfs_dataset_used_bytes{name="tank/video",job="swan"}'';
                          legendFormat = "__auto";
                          range = true;
                          refId = "A";
                        }
                      ];
                      title = "Video Library";
                      transparent = true;
                      type = "stat";
                    }

                    # NAS Storage
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          decimals = 0;
                          mappings = [ ];
                          max = 1;
                          min = 0;
                          thresholds = {
                            mode = "percentage";
                            steps = [
                              {
                                color = "super-light-green";
                                value = null;
                              }
                            ];
                          };
                          unit = "percentunit";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 2;
                        w = 4;
                        x = 19;
                        y = 1;
                      };
                      id = 38;
                      options = {
                        displayMode = "basic";
                        minVizHeight = 10;
                        minVizWidth = 0;
                        orientation = "horizontal";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        showUnfilled = true;
                        valueMode = "color";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = ''zfs_dataset_used_bytes{name="tank"} / zfs_dataset_available_bytes{name="tank"}'';
                          hide = false;
                          legendFormat = "{{name}}";
                          range = true;
                          refId = "A";
                        }
                      ];
                      title = "NAS Storage";
                      transformations = [ ];
                      transparent = true;
                      type = "bargauge";
                    }

                    # NAS Growth
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            fixedColor = "#2b462f";
                            mode = "fixed";
                          };
                          decimals = 0;
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "super-light-green";
                                value = null;
                              }
                            ];
                          };
                          unit = "bytes";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 10;
                        w = 4;
                        x = 19;
                        y = 3;
                      };
                      id = 55;
                      options = {
                        colorMode = "background";
                        graphMode = "area";
                        justifyMode = "auto";
                        orientation = "horizontal";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        textMode = "auto";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          "expr" = ''delta(zfs_dataset_used_bytes{name="tank"}[1d])'';
                          hide = false;
                          instant = false;
                          interval = "";
                          legendFormat = "Past Day";
                          range = true;
                          refId = "A";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          "expr" = ''delta(zfs_dataset_used_bytes{name="tank"}[7d])'';
                          hide = false;
                          legendFormat = "Past Week";
                          range = true;
                          refId = "B";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          "expr" = ''delta(zfs_dataset_used_bytes{name="tank"}[30d])'';
                          hide = false;
                          legendFormat = "Past Month";
                          range = true;
                          refId = "C";
                        }
                      ];
                      title = "NAS Growth";
                      transformations = [ ];
                      transparent = true;
                      type = "stat";
                    }

                    # Caddy Upstreams
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "palette-classic";
                          };
                          custom = {
                            fillOpacity = 69;
                            lineWidth = 2;
                            spanNulls = false;
                          };
                          mappings = [
                            {
                              options = {
                                "0" = {
                                  color = "#d13b4d";
                                  index = 1;
                                  text = "Down";
                                };
                                "1" = {
                                  color = "#33372c";
                                  index = 0;
                                  text = "Up";
                                };
                              };
                              type = "value";
                            }
                          ];
                          noValue = "0";
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "green";
                                value = null;
                              }
                            ];
                          };
                        };
                        overrides = [
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:${builtins.toString config.services.jellyseerr.port}";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Jellyseerr";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.download}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:${builtins.toString config.services.bazarr.listenPort}";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Bazarr";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.download}/bazarr";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:7878";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Radarr";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.download}/radarr";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:8787";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Readarr";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.download}/readarr";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "unix//run/phpfpm/nextcloud.sock";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Nextcloud";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.content}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:${builtins.toString config.services.calibre-web.listen.port}";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Calibre";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.books}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:8085";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Sabnzbd";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.download}/sabnzbd";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:8086";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "InfluxDB";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.influxdb}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:8096";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Jellyfin";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.stream}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:8989";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Sonarr";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.download}/sonarr";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:9000";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "The Lounge";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.irc}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:9696";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Prowlarr";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.download}/prowlarr";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:${builtins.toString config.services.grafana.settings.server.http_port}";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Grafana";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.metrics}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:${builtins.toString config.services.gitea.settings.server.HTTP_PORT}";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Gitea";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.git}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:${builtins.toString config.services.vaultwarden.config.ROCKET_PORT}";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Vaultwarden";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.secrets}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:8427";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "VictoriaMetrics";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.prometheus}/vmui";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:${builtins.toString config.services.paperless.port}";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Paperless";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.paperless}";
                                  }
                                ];
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "localhost:${builtins.toString config.services.audiobookshelf.port}";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Audiobookshelf";
                              }
                              {
                                id = "links";
                                value = [
                                  {
                                    targetBlank = true;
                                    title = "";
                                    url = "https://${config.hostnames.audiobooks}";
                                  }
                                ];
                              }
                            ];
                          }
                        ];
                      };
                      gridPos = {
                        h = 8;
                        w = 7;
                        x = 0;
                        y = 5;
                      };
                      id = 21;
                      options = {
                        alignValue = "left";
                        legend = {
                          displayMode = "list";
                          placement = "bottom";
                          showLegend = false;
                        };
                        mergeValues = true;
                        rowHeight = 0.65;
                        showValue = "never";
                        tooltip = {
                          mode = "single";
                          sort = "none";
                        };
                      };
                      pluginVersion = "9.5.3";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "caddy_reverse_proxy_upstreams_healthy{}";
                          instant = false;
                          legendFormat = "{{upstream}}";
                          range = true;
                          refId = "A";
                        }
                      ];
                      title = "Caddy Upstreams";
                      transparent = true;
                      type = "state-timeline";
                    }

                    # Stream Stats
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            fixedColor = "#5b79b0";
                            mode = "fixed";
                          };
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "green";
                                value = null;
                              }
                            ];
                          };
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 4;
                        w = 6;
                        x = 7;
                        y = 5;
                      };
                      id = 108;
                      options = {
                        colorMode = "background";
                        graphMode = "none";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        textMode = "auto";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = ''increase(http_requests_received_total{endpoint="Sessions/Playing"}[1d])'';
                          instant = false;
                          legendFormat = "Past Day";
                          range = true;
                          refId = "A";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = ''increase(http_requests_received_total{endpoint="Sessions/Playing"}[7d])'';
                          hide = false;
                          legendFormat = "Past Week";
                          range = true;
                          refId = "B";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = ''increase(http_requests_received_total{endpoint="Sessions/Playing"}[30d])'';
                          hide = false;
                          legendFormat = "Past Month";
                          range = true;
                          refId = "C";
                        }
                      ];
                      title = "Streams";
                      transparent = true;
                      type = "stat";
                    }

                    # Media Stats
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            fixedColor = "#895d3a";
                            mode = "fixed";
                          };
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "green";
                                value = null;
                              }
                            ];
                          };
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 4;
                        w = 6;
                        x = 13;
                        y = 5;
                      };
                      id = 105;
                      options = {
                        colorMode = "background";
                        graphMode = "none";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        textMode = "auto";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "radarr_movie_downloaded_total";
                          hide = false;
                          instant = true;
                          legendFormat = "Movies";
                          range = false;
                          refId = "C";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "sonarr_series_downloaded_total";
                          hide = false;
                          instant = true;
                          legendFormat = "TV Shows";
                          range = false;
                          refId = "B";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "sonarr_episode_downloaded_total";
                          instant = true;
                          legendFormat = "TV Episodes";
                          range = false;
                          refId = "A";
                        }
                      ];
                      title = "Media";
                      transparent = true;
                      type = "stat";
                    }

                    # Downloader Status
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "#bc5460";
                                value = null;
                              }
                            ];
                          };
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 4;
                        w = 2;
                        x = 7;
                        y = 9;
                      };
                      id = 134;
                      options = {
                        colorMode = "background";
                        graphMode = "none";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        textMode = "name";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "sabnzbd_info";
                          instant = true;
                          legendFormat = "{{status}}";
                          range = false;
                          refId = "A";
                        }
                      ];
                      title = "Downloader";
                      transparent = true;
                      type = "stat";
                    }

                    # Downloader Stats
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            fixedColor = "#895d3a";
                            mode = "fixed";
                          };
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "green";
                                value = null;
                              }
                            ];
                          };
                          unit = "bytes";
                        };
                        overrides = [
                          {
                            matcher = {
                              id = "byName";
                              options = "Queue";
                            };
                            properties = [
                              {
                                id = "unit";
                                value = "none";
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "Completed";
                            };
                            properties = [
                              {
                                id = "unit";
                                value = "none";
                              }
                            ];
                          }
                        ];
                      };
                      gridPos = {
                        h = 4;
                        w = 8;
                        x = 9;
                        y = 9;
                      };
                      id = 106;
                      options = {
                        colorMode = "background";
                        graphMode = "none";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        textMode = "auto";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = "sabnzbd_queue_length";
                          hide = false;
                          legendFormat = "Queue";
                          range = true;
                          refId = "C";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = "sum(prowlarr_indexer_grabs_total[$__range])";
                          hide = false;
                          legendFormat = "Completed";
                          range = true;
                          refId = "D";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "increase(sabnzbd_downloaded_bytes[7d])";
                          hide = false;
                          instant = true;
                          legendFormat = "Week";
                          range = false;
                          refId = "A";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "sabnzbd_downloaded_bytes";
                          hide = false;
                          instant = true;
                          legendFormat = "Total";
                          range = false;
                          refId = "B";
                        }
                      ];
                      title = "Downloads";
                      transparent = true;
                      type = "stat";
                    }

                    # Download Requests
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            fixedColor = "#723f3f";
                            mode = "fixed";
                          };
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "green";
                                value = null;
                              }
                            ];
                          };
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 4;
                        w = 2;
                        x = 17;
                        y = 9;
                      };
                      id = 135;
                      options = {
                        colorMode = "background";
                        graphMode = "none";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        textMode = "auto";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = "radarr_movie_missing_total";
                          instant = true;
                          legendFormat = "Movies";
                          range = false;
                          refId = "A";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = "sonarr_episode_missing_total";
                          hide = false;
                          legendFormat = "Episodes";
                          range = true;
                          refId = "B";
                        }
                      ];
                      title = "Requests";
                      transparent = true;
                      type = "stat";
                    }

                    # CPU by Host
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          decimals = 2;
                          mappings = [ ];
                          max = 1;
                          min = 0;
                          thresholds = {
                            mode = "percentage";
                            steps = [
                              {
                                color = "#a82e3c";
                                value = null;
                              }
                              {
                                color = "red";
                                value = 90;
                              }
                            ];
                          };
                          unit = "percentunit";
                        };
                        overrides = [
                          {
                            matcher = {
                              id = "byName";
                              options = "flame";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Flame 🔥";
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "swan";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Swan 🦢";
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "tempest";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Tempest 🌊";
                              }
                            ];
                          }
                        ];
                      };
                      gridPos = {
                        h = 4;
                        w = 7;
                        x = 0;
                        y = 13;
                      };
                      id = 72;
                      options = {
                        displayMode = "basic";
                        minVizHeight = 10;
                        minVizWidth = 0;
                        orientation = "horizontal";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        showUnfilled = true;
                        valueMode = "color";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = ''sort_desc(max(irate(node_cpu_seconds_total{instance="127.0.0.1:${builtins.toString config.services.prometheus.exporters.node.port}",mode=~"system|user"}[$__range])) by (job))'';
                          instant = true;
                          legendFormat = "__auto";
                          range = false;
                          refId = "A";
                        }
                      ];
                      title = "CPU";
                      transformations = [ ];
                      transparent = true;
                      type = "bargauge";
                    }

                    # Memory by Host
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          decimals = 2;
                          mappings = [ ];
                          max = 1;
                          min = 0;
                          thresholds = {
                            mode = "percentage";
                            steps = [
                              {
                                color = "#ce95ca";
                                value = null;
                              }
                              {
                                color = "semi-dark-red";
                                value = 90;
                              }
                            ];
                          };
                          unit = "percentunit";
                        };
                        overrides = [
                          {
                            matcher = {
                              id = "byName";
                              options = "tempest";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Tempest 🌊";
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "swan";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Swan 🦢";
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "flame";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Flame 🔥";
                              }
                            ];
                          }
                        ];
                      };
                      gridPos = {
                        h = 4;
                        w = 7;
                        x = 7;
                        y = 13;
                      };
                      id = 73;
                      options = {
                        displayMode = "basic";
                        minVizHeight = 10;
                        minVizWidth = 0;
                        orientation = "horizontal";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        showUnfilled = true;
                        valueMode = "color";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          "expr" = "sort_desc(node_memory_Active_bytes/node_memory_MemTotal_bytes)";
                          instant = true;
                          legendFormat = "{{job}}";
                          range = false;
                          refId = "A";
                        }
                      ];
                      title = "Memory";
                      transformations = [
                        {
                          id = "sortBy";
                          options = { };
                        }
                      ];
                      transparent = true;
                      type = "bargauge";
                    }

                    # Storage by Host
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          decimals = 2;
                          mappings = [ ];
                          max = 1;
                          min = 0;
                          thresholds = {
                            mode = "percentage";
                            steps = [
                              {
                                color = "#dbda61";
                                value = null;
                              }
                              {
                                color = "semi-dark-red";
                                value = 90;
                              }
                            ];
                          };
                          unit = "percentunit";
                        };
                        overrides = [
                          {
                            matcher = {
                              id = "byName";
                              options = "flame";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Flame 🔥";
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "swan";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Swan 🦢";
                              }
                            ];
                          }
                          {
                            matcher = {
                              id = "byName";
                              options = "tempest";
                            };
                            properties = [
                              {
                                id = "displayName";
                                value = "Tempest 🌊";
                              }
                            ];
                          }
                        ];
                      };
                      gridPos = {
                        h = 4;
                        w = 7;
                        x = 14;
                        y = 13;
                      };
                      id = 74;
                      options = {
                        displayMode = "basic";
                        minVizHeight = 10;
                        minVizWidth = 0;
                        orientation = "horizontal";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        showUnfilled = true;
                        valueMode = "color";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = ''sort_desc((node_filesystem_size_bytes{mountpoint="/"} - node_filesystem_avail_bytes{mountpoint="/"}) / node_filesystem_size_bytes{mountpoint="/"})'';
                          instant = true;
                          legendFormat = "{{job}}";
                          range = false;
                          refId = "A";
                        }
                      ];
                      title = "Storage";
                      transformations = [ ];
                      transparent = true;
                      type = "bargauge";
                    }

                    # Host Bar
                    {
                      collapsed = false;
                      gridPos = {
                        h = 1;
                        w = 24;
                        x = 0;
                        y = 17;
                      };
                      id = 16;
                      panels = [ ];
                      repeat = "host";
                      repeatDirection = "h";
                      title = "Host";
                      type = "row";
                    }

                    # Host Label
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          mappings = [
                            {
                              options = {
                                flame = {
                                  color = "orange";
                                  index = 2;
                                  text = "Flame 🔥";
                                };
                                swan = {
                                  color = "text";
                                  index = 1;
                                  text = "Swan 🦢";
                                };
                                tempest = {
                                  color = "#6fa8e1";
                                  index = 0;
                                  text = "Tempest 🌊";
                                };
                              };
                              type = "value";
                            }
                          ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "dark-blue";
                                value = null;
                              }
                            ];
                          };
                          unit = "none";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 3;
                        w = 3;
                        x = 0;
                        y = 18;
                      };
                      id = 19;
                      options = {
                        colorMode = "value";
                        graphMode = "none";
                        justifyMode = "auto";
                        orientation = "auto";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "/^job$/";
                          values = false;
                        };
                        textMode = "auto";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = ''node_os_info{job="$host"}'';
                          format = "table";
                          legendFormat = "__auto";
                          range = true;
                          refId = "A";
                        }
                      ];
                      title = "Host";
                      transparent = true;
                      type = "stat";
                    }

                    # Vitals
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            mode = "thresholds";
                          };
                          decimals = 0;
                          mappings = [ ];
                          max = 1;
                          min = 0;
                          thresholds = {
                            mode = "percentage";
                            steps = [
                              {
                                color = "super-light-green";
                                value = null;
                              }
                              {
                                color = "orange";
                                value = 70;
                              }
                              {
                                color = "red";
                                value = 90;
                              }
                            ];
                          };
                          unit = "percentunit";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 5;
                        w = 6;
                        x = 3;
                        y = 18;
                      };
                      id = 123;
                      options = {
                        displayMode = "basic";
                        minVizHeight = 10;
                        minVizWidth = 0;
                        orientation = "horizontal";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        showUnfilled = true;
                        valueMode = "color";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = ''max(irate(node_cpu_seconds_total{job="$host",instance="127.0.0.1:${builtins.toString config.services.prometheus.exporters.node.port}",mode=~"system|user"}[$__range]))'';
                          hide = false;
                          legendFormat = "CPU";
                          range = true;
                          refId = "C";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          expr = ''(node_memory_Active_bytes{job="$host"})/node_memory_MemTotal_bytes{job="$host"}'';
                          hide = false;
                          legendFormat = "Memory";
                          range = true;
                          refId = "B";
                        }
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = ''(node_filesystem_size_bytes{mountpoint="/",job="$host"} - node_filesystem_avail_bytes{mountpoint=~"/",job="$host"}) / node_filesystem_size_bytes{mountpoint="/",job="$host"}'';
                          instant = true;
                          legendFormat = "Storage";
                          range = false;
                          refId = "A";
                        }
                      ];
                      title = "Vitals";
                      transformations = [ ];
                      transparent = true;
                      type = "bargauge";
                    }

                    # Top Processes by CPU
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      description = "";
                      fieldConfig = {
                        defaults = {
                          color = {
                            fixedColor = "#c4af88";
                            mode = "fixed";
                          };
                          decimals = 2;
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "green";
                                value = null;
                              }
                              {
                                color = "red";
                                value = 10000000;
                              }
                            ];
                          };
                          unit = "percentunit";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 8;
                        w = 6;
                        x = 12;
                        y = 18;
                      };
                      id = 14;
                      options = {
                        displayMode = "basic";
                        minVizHeight = 10;
                        minVizWidth = 0;
                        orientation = "horizontal";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        showUnfilled = true;
                        valueMode = "color";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = ''topk(5, irate(namedprocess_namegroup_cpu_seconds_total{job="$host"}[$__range]))'';
                          instant = true;
                          legendFormat = "{{groupname}}";
                          range = false;
                          refId = "A";
                        }
                      ];
                      title = "Top Processes - CPU";
                      transparent = true;
                      type = "bargauge";
                    }

                    # Top Processes by Memory
                    {
                      datasource = {
                        type = "prometheus";
                        uid = promUid;
                      };
                      fieldConfig = {
                        defaults = {
                          color = {
                            fixedColor = "#afb091";
                            mode = "fixed";
                          };
                          mappings = [ ];
                          thresholds = {
                            mode = "absolute";
                            steps = [
                              {
                                color = "green";
                                value = null;
                              }
                              {
                                color = "red";
                                value = 10000000;
                              }
                            ];
                          };
                          unit = "bytes";
                        };
                        overrides = [ ];
                      };
                      gridPos = {
                        h = 8;
                        w = 6;
                        x = 18;
                        y = 18;
                      };
                      id = 15;
                      options = {
                        displayMode = "basic";
                        minVizHeight = 10;
                        minVizWidth = 0;
                        orientation = "horizontal";
                        reduceOptions = {
                          calcs = [ "lastNotNull" ];
                          fields = "";
                          values = false;
                        };
                        showUnfilled = true;
                        valueMode = "color";
                      };
                      pluginVersion = "10.0.2";
                      targets = [
                        {
                          datasource = {
                            type = "prometheus";
                            uid = promUid;
                          };
                          editorMode = "code";
                          exemplar = false;
                          expr = ''topk(5, rate(namedprocess_namegroup_memory_bytes{memtype="resident",job="$host"}[$__range]))'';
                          instant = true;
                          legendFormat = "{{groupname}}";
                          range = false;
                          refId = "A";
                        }
                      ];
                      title = "Top Processes - Memory";
                      transparent = true;
                      type = "bargauge";
                    }
                  ];

                  refresh = "10s";
                  schemaVersion = 38;
                  style = "dark";
                  tags = [ ];
                  templating = {
                    list = [
                      {
                        current = {
                          selected = true;
                          text = [ "All" ];
                          value = [ "$__all" ];
                        };
                        datasource = {
                          type = "prometheus";
                          uid = promUid;
                        };
                        definition = "label_values(nodename)";
                        hide = 0;
                        includeAll = true;
                        label = "Host";
                        multi = true;
                        name = "host";
                        options = [ ];
                        query = {
                          query = "label_values(nodename)";
                          refId = "PrometheusVariableQueryEditor-VariableQuery";
                        };
                        refresh = 1;
                        regex = "";
                        skipUrlSync = false;
                        sort = 1;
                        type = "query";
                      }
                    ];
                  };
                  time = {
                    from = "now-6h";
                    to = "now";
                  };
                  timepicker = { };
                  timezone = "";
                  title = "Main";
                  uid = "main";
                  version = 60;
                  weekStart = "";
                }
              ))
            }/dashboards";
          }
        ];

        alerting = {

          contactPoints.settings.contactPoints = [
            {
              name = "grafana-default-email";
              receivers = [
                {
                  uid = "basic-email";
                  type = "email";
                  settings.addresses = "grafana@${config.mail.server}";
                }
              ];
            }
          ];

          muteTimings = { };
          policies.settings = {
            resetPolicies = [ 1 ];
          };

          rules.settings.groups = [
            {
              name = "Default";
              interval = "1m";
              folder = "Alerts";
              rules = [
                {
                  uid = "cloudflare-tunnel";
                  title = "Cloudflare Tunnel";
                  condition = "C";
                  data = [

                    # Query to retrieve the status data
                    {
                      refId = "A";
                      relativeTimeRange = {
                        from = 600;
                        to = 0;
                      };
                      datasourceUid = promUid;
                      model = {
                        editorMode = "code";
                        expr = ''systemd_unit_state{name=~"cloudflared-tunnel-.*", state="active", job!="tempest"}'';
                        hide = false;
                        instant = true;
                        intervalMs = 1000;
                        maxDataPoints = 43200;
                        range = false;
                        refId = "A";
                      };
                    }

                    # Reduce to the max level, to ensure no false alarms
                    {
                      refId = "B";
                      relativeTimeRange = {
                        from = 600;
                        to = 0;
                      };
                      datasourceUid = "__expr__";
                      model = {
                        conditions = [
                          {
                            evaluator = {
                              params = [ ];
                              type = "gt";
                            };
                            operator = {
                              type = "and";
                            };
                            query = {
                              params = [ "B" ];
                            };
                            reducer = {
                              params = [ ];
                              type = "last";
                            };
                            type = "query";
                          }
                        ];
                        datasource = {
                          type = "__expr__";
                          uid = "__expr__";
                        };
                        expression = "A";
                        hide = false;
                        intervalMs = 1000;
                        maxDataPoints = 43200;
                        reducer = "max";
                        refId = "B";
                        type = "reduce";
                      };
                    }

                    # Threshold to trigger alarm if below 100% uptime
                    {
                      refId = "C";
                      relativeTimeRange = {
                        from = 600;
                        to = 0;
                      };
                      datasourceUid = "__expr__";
                      model = {
                        conditions = [
                          {
                            evaluator = {
                              params = [ 1 ];
                              type = "lt";
                            };
                            operator = {
                              type = "and";
                            };
                            query = {
                              params = [ "C" ];
                            };
                            reducer = {
                              params = [ ];
                              type = "last";
                            };
                            type = "query";
                          }
                        ];
                        datasource = {
                          type = "__expr__";
                          uid = "__expr__";
                        };
                        expression = "B";
                        hide = false;
                        intervalMs = 1000;
                        maxDataPoints = 43200;
                        refId = "C";
                        type = "threshold";
                      };
                    }
                  ];
                  noDataState = "Alerting";
                  execErrState = "Error";
                  for = "5m";
                  annotations = {
                    description = "Cloudflare Tunnel for {{ index $labels \"job\" }}.";
                    summary = "Cloudflare Tunnel is down.";
                  };
                  isPaused = false;
                }
              ];
            }
          ];

          templates = { };
        };

        # notifiers = [];
      };
    };

    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.metrics ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${builtins.toString config.services.grafana.settings.server.http_port}"; }
            ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.metrics ];
  };
}
