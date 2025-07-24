(use-modules (shepherd service)
             (shepherd support)
             (ice-9 match))

(define guacd-service
  (service
   (provision '(guacamole-daemon))
   (documentation "Run the Guacamole daemon (guacd) as a user service.")
   (requirement '())
   (start
    #~(lambda _
        (fork+exec-command
         (list #$(file-append (specification->package "guacamole-server") "/bin/guacd")
               "-b" "0.0.0.0"
               "-L" "4823" ; Unprivileged port
               "-l" "debug" ; Log level: info, debug, etc.
               "-f") ; Foreground mode for logging
         #:log-file (string-append (getenv "HOME") "/.cache/guacd.log"))))
   (stop
    #~(make-kill-destructor))
   (actions
    (list
     (shepherd-action
      (name 'restart)
      (documentation "Restart the guacd service.")
      (procedure
       (lambda (running)
         (stop running)
         (start running))))))))

(register-services guacd-service)

(action 'shepherd 'daemonize)
