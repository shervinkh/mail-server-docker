require [ "vnd.dovecot.filter" ];
filter "spamc" [ "-d", "127.0.0.1", "--no-safe-fallback" ];
