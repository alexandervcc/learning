$ttl 86400
@       IN      SOA     ns.cheems.com.  hostmaster.cheems.com.(
                        202      ; Serial
                        600      ; Refresh
                        3600     ; Retry
                        1209600  ; Expire
                        3600)    ; Negative Cache TTL

@       IN      NS      ns.cheems.com.
ns      IN      A       127.0.0.1