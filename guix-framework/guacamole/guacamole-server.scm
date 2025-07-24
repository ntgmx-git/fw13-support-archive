(define-module (guacamole-server)
	       #:use-module (guix packages)
	       #:use-module (guix download)
	       #:use-module (guix build-system gnu)
	       #:use-module (guix licenses)
	       #:use-module (gnu packages gawk)
	       #:use-module (gnu packages gtk)
	       #:use-module (gnu packages image)
	       #:use-module (gnu packages autotools)
	       #:use-module (gnu packages linux)
	       #:use-module (gnu packages vnc)
	       #:use-module (gnu packages ssh)
	       #:use-module (gnu packages video)
	       #:use-module (nongnu packages video)
	       #:use-module (gnu packages pkg-config)
	       #:use-module (gnu packages web)
	       #:use-module (gnu packages rdesktop)
	       #:use-module (gnu packages perl)
	       #:use-module (gnu packages pulseaudio)
	       #:use-module (gnu packages check)
	       #:use-module (gnu packages tls))

(define-public guacamole-server
	       (package
		 (name "guacamole-server")
		 (version "1.5.5")
		 (source (origin
			   (method url-fetch)
			   (uri (string-append "https://github.com/apache/guacamole-server/archive/refs/tags/" version ".tar.gz"))
			   (sha256
			     (base32
			       "07kkkh1lfqq1csk9c9knkwd8rvpd1jmnyhv07v6z54iv1w7hqhsh"))))
		 (build-system gnu-build-system)
		 (arguments 
		   `(#:tests? #f))
		     ;#:phases
		     ;(modify-phases %standard-phases ;https://grok.com/share/c2hhcmQtMg%3D%3D_0546c774-37a0-4470-ab55-12c8f97cb820
		;		    (add-before 'configure 'patch-perl-shebang
		;				(lambda _
		;				  (substitute* '("src/protocols/rdp/plugins/generate-entry-wrappers.pl"
		;						 "src/protocols/rdp/keymaps/generate.pl")
		;					       (("#!.*perl")
		;						(string-append "#!" (which "perl"))))
		;				  #t)))))
		 (inputs (list perl 
			       pkg-config 
			       autoconf-archive 
			       autoconf 
			       automake 
			       libtool 
			       ffmpeg-nvenc 
			       gawk 
			       cunit
			       cairo 
			       libjpeg-turbo 
			       libpng 
			       libtool 
			       util-linux 
			       ffmpeg 
			       ;freerdp 
			       pango 
			       libssh2 
			       libvnc 
			       libwebsockets 
			       pulseaudio 
			       openssl 
			       libwebp))
		 (synopsis "The guacamole-server package is a set of software which forms the basis of the Guacamole stack. It consists of guacd, libguac, and several protocol support libraries.")
		 (description "guacd is the Guacamole proxy daemon used by the Guacamole web application and framework. As JavaScript cannot handle binary protocols (like VNC and remote desktop) efficiently, a new text-based protocol was developed which would contain a common superset of the operations needed for efficient remote desktop access, but would be easy for JavaScript programs to process. guacd is the proxy which translates between arbitrary protocols and the Guacamole protocol.")
		 (home-page "https://guacamole.apache.org")
		 (license asl2.0)))
guacamole-server
