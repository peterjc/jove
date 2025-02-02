##########################################################################
# This program is Copyright (C) 1986-2002 by Jonathan Payne.  JOVE is    #
# provided by Jonathan and Jovehacks without charge and without          #
# warranty.  You may copy, modify, and/or distribute JOVE, provided that #
# this notice is included in all the source files and documentation.     #
##########################################################################

# SHELL for this Makefile (csh won't work!)
SHELL = /bin/sh

# If the system has no cmp, not a big deal, minor optimization to prevent
# a few needless rebuilds
CMP = cmp

# JOVEHOME is the directory in which pieces of JOVE are kept.  It is only used
#	in the default definitions of JSHAREDIR, JLIBDIR, JBINDIR, and JMANDIR.
# JSHAREDIR is for online documentation, and the distributed standard system-wide
# jove.rc file with some common
# JLIBDIR is for the PORTSRV and RECOVER programs.
# JBINDIR is where to put the executables JOVE and TEACHJOVE.
# XEXT is the extension for executables (empty for UNIX; .exe for CYGWIN)
# JMANDIR is where the manual pages go for JOVE, RECOVER and TEACHJOVE.
# MANEXT is the extension for the man pages, e.g., jove.1 or jove.l or jove.m.
#	Must not be "nr".
# JTEACHBASE is the basename of the installed teach-jove tutorial file,
# which will be teachjov.txt on MSFILESYSTEM (and the zip file),
# but teach-jove on Unix/Linux installs.
#
# If they don't exist, this makefile will try to create all *DIR directories
# (prefixed with $DESTDIR, as most packaging systems desire)
# All others must already exist.
#
# Hack for relocatable installs: set JSHAREDIR and JLIBDIR and JBINDIR to relative 
# paths, and set DESTDIR to an empty directory.

JOVEHOME = /usr/local
JREL =
JSHAREDIR = $(JOVEHOME)/share/jove
DSHAREDIR = $(DESTDIR)$(JSHAREDIR)
JLIBDIR = $(JOVEHOME)/lib/jove
DLIBDIR = $(DESTDIR)$(JLIBDIR)
JBINDIR = $(JOVEHOME)/bin
DBINDIR = $(DESTDIR)$(JBINDIR)
XEXT=
JMANDIR = $(JOVEHOME)/man/man$(MANEXT)
DMANDIR = $(DESTDIR)$(JMANDIR)
MANEXT = 1
JTEACHBASE = teach-jove

# Install permission for SHAREDIR, LIBDIR, BINDIR
DPERM = 755
XPERM = 755

# JTMPDIR is where the tmp files get stored, usually /tmp, /var/tmp, or
# /usr/tmp.  If you wish to be able to recover buffers after a system
# crash, this needs to be a directory that isn't cleaned out on reboot.
# You would probably want to clean out that directory periodically with
# /etc/cron.
# JRECDIR is the directory in which RECOVER looks for JOVE's tempfiles
# (in case the system startup salvages tempfiles by moving them,
# which is probably a good idea).

JETCDIR = /etc/jove
DETCDIR = $(DESTDIR)$(JETCDIR)
JTMPDIR = /var/tmp
JRECDIR = /var/lib/jove/preserve
DRECDIR = $(DESTDIR)$(JRECDIR)

# Install permission for DRECDIR
RECPERM = 1777

# place to copy source tarball for rpmbuild
RPMHOME = $(HOME)/rpmbuild/SOURCES

# DFLTSHELL is the default shell invoked by JOVE.
DFLTSHELL = /bin/sh

# The install commands of BSD and System V differ in unpleasant ways:
# -c: copy (BSD); -c dir: destination directory (SysV)
# -s: strip (BSD); -s: suppress messages (SysV)
# Also, the destination specification is very different.
# The result is that the System V install command must not be used.
# If you know that /bin/install is the BSD program, you can use it.
# "cp" will work reasonably well, but be aware that any links continue
# referencing the old file with new contents.

INSTALLFLAGS = # -g bin -o root

# XINSTALL to install executable files, prefer install since it is independent
# of user umask
# Linux/modern BSD/CYGWIN
XINSTALL=install $(INSTALLFLAGS) -m 755
TINSTALL=install $(INSTALLFLAGS) -m 444

# These should all just be right if the above ones are.
# You will confuse JOVE if you move anything from LIBDIR or SHAREDIR.

JOVE = $(DBINDIR)/jove$(XEXT)
TEACHJOVE = $(DBINDIR)/teachjove
RECOVER = $(DLIBDIR)/recover$(XEXT)
PORTSRV = $(DLIBDIR)/portsrv$(XEXT)
JOVERC = $(DSHAREDIR)/jove.rc
TERMSDIR = $(DSHAREDIR)
CMDSDOC = $(DSHAREDIR)/cmds.doc
TEACHJOVEDOC = $(DSHAREDIR)/$(JTEACHBASE)
JOVEM = $(DMANDIR)/jove.$(MANEXT)
TEACHJOVEM = $(DMANDIR)/teachjove.$(MANEXT)
XJOVEM = $(DMANDIR)/xjove.$(MANEXT)
JOVETOOLM = $(DMANDIR)/jovetool.$(MANEXT)

# We set CFLAGS to SYSDEFS and OPTFLAGS, so we can set
# the definitions in SYSDEFS (needed for the local compiler
# of keys.c, and the target compiler for the rest, in order
# to make this work for cross-compilation)

# SYSDEFS: specify system characteristics to the C preprocessor using -D options
# The default is the system uname, which should work for many
# popular modern systems like Linux, *BSD, OpenIndiana.
# If sysdep.h does not define a block for your system, or uname produces
# an illegal symbol on your platform (Cygwin, GNU Hurd), use jmake
# or see README, sysdep.h, sysdep.doc.
# XXX Among modern systems, FreeBSD does not put CPPFLAGS in the default
# .c.o make build rules, so we put it in SYSDEFS, which we then add
# to CFLAGS.  This means the contents of CPPFLAGS will likely 
# appear twice in cc invocations on non-FreeBSD (i.e. OpenBSD, NetBSD, Linux)
# so best to avoid setting it (the default value is empty anyway)
SYSDEFS = -D`uname` -DJTC $(CPPFLAGS)

# OPTFLAGS: compiler flags that are passed to both the compiling & linking steps
# e.g. -g for debugging, -O for optimization.
OPTFLAGS = -O

# CFLAGS (i.e compile flags for the target compiler) are OPTFLAGS and SYSDEFS,
# DO NOT OVERRIDE
CFLAGS = $(OPTFLAGS) $(SYSDEFS)

# For making dependencies under BSD systems
DEPENDFLAG = -M
# or, using the official Sun ANSI C compiler
#	DEPENDFLAG = -xM

# Flags for Libraries to provide termcap and pty functions.
# Some modern open-source systems have dropped termcap, or ship it
# as part of the ncurses or tinfo packages.
# For systems without dynamic libraries, termcap or terminfo are smaller,
# and preferable to the bulkier curses library.
# Jove comes with a simplified termcap substitute that only supports
# ANSI X.3/VT[1-5]xx or compatible terminal emulators like xterm, rxvt, etc,
# which is almost certainly all that is necessary on modern machines.
# To use it, define -DJTC and leave TERMCAPLIB unset

TERMCAPLIB = # for compatibility with old packagers, deprecated, use LDLIBS
EXTRALIBS = -lutil # for compatibility with old packagers, deprecated, use LDLIBS
LDLIBS = $(TERMCAPLIB) $(EXTRALIBS)

# linker flags (LDFLAGS) not needed for most systems
LDFLAGS = 

# LDCC can be used for link-time alternatives to CC.  Also useful
# for purify or similar link-time processing.
LDCC = $(CC)

# For cross compiling Jove, set CC to the cross compiler, and LOCALCC
# to the local C compiler. LOCALCC will be used for compiling setmaps,
# which is run as part of the compilation to generate the keymaps.
# Set LOCALCFLAGS and LOCALLDFLAGS to anything extra (other than SYSDEFS,
# which must be the same for local and cross, so that setmaps generates
# the correct key bindings), though no optimization or debug or special
# flags are usually needed (other than Xenix?!), since setmaps is 
# run just once, so use whatever compiles fastest.

LOCALCC = $(CC)
LOCALCFLAGS = # nothing really needed for setmaps
LOCALLDFLAGS = $(LDFLAGS)
LOCALEXTRALIBS = # nothing really needed for setmaps
LOCALEXT = # default is a Un*x-style machine, not Windows

# Objects are grouped into overlays for the benefit of (at least) 2.xBSD.

BASESEG = commands.o keys.o argcount.o ask.o buf.o jctype.o delete.o \
	  disp.o insert.o io.o jove.o marks.o misc.o re.o \
	  screen.o termcap.o unix.o util.o vars.o list.o keymaps.o \
	  mouse.o jtc.o
OVLAY1 = abbrev.o rec.o para.o fmt.o
OVLAY2 = c.o wind.o fp.o move.o
OVLAY3 = extend.o macros.o
OVLAY4 = iproc.o reapp.o
OVLAY5 = proc.o scandir.o term.o case.o

OBJECTS = $(BASESEG) $(OVLAY1) $(OVLAY2) $(OVLAY3) $(OVLAY4) $(OVLAY5)

# win32.o when cross-compiling with mingw for Win32
EXTRAOBJS =
# jjove.coff for cross-compiling with mingw for Win32
ICON = 
WINDRES = windres # probably needs i686-w64-mingw32- prefix or similar

ZIP=zip
ZIPEXT=zip
ZIPOPTS=-q -k	# common options for both binary and code files
ZIPTXTOPT=-l -r	# options for recursively adding code files
TAR=tar
BACKUPDEV=/dev/rst8	# for tape-backup target!

# These NROFF, TROFF and TROFFPOST settings work with groff.
# Classic Unix and derivatives used to have ditroff, for which use:
#	NROFF = nroff
#	TROFF = troff
#	TROFFPOST = | /usr/lib/lp/postscript/dpost -
NROFF = nroff -Tascii
TROFF = troff
TROFFPOST = 

MANUALS = $(JOVEM) $(TEACHJOVEM)

C_SRC = commands.c commands.tab abbrev.c argcount.c ask.c buf.c c.c case.c jctype.c \
	delete.c disp.c extend.c fp.c fmt.c insert.c io.c iproc.c \
	jove.c jtc.c list.c macros.c marks.c misc.c move.c para.c \
	proc.c re.c reapp.c rec.c scandir.c screen.c term.c termcap.c unix.c \
	util.c vars.c vars.tab wind.c msgetch.c mac.c keymaps.c ibmpcdos.c \
	mouse.c win32.c

SOURCES = $(C_SRC) portsrv.c recover.c setmaps.c

HEADERS = abbrev.h argcount.h ask.h buf.h c.h case.h chars.h commands.h \
	jctype.h dataobj.h delete.h disp.h extend.h externs.h \
	fmt.h fp.h insert.h io.h iproc.h jove.h \
	keymaps.h list.h mac.h macros.h marks.h \
	misc.h mouse.h move.h para.h proc.h \
	re.h reapp.h rec.h recover.h scandir.h screen.h \
	select.h sysdep.h sysprocs.h temp.h term.h ttystate.h \
	tune.h util.h vars.h version.h wind.h

DOCTERMS =	doc/jove.rc.sun doc/keychart.sun \
	doc/jove.rc.sun-cmd doc/keychart.sun-cmd \
	doc/jove.rc.vt100 doc/keychart.vt100 \
	doc/jove.rc.wyse doc/keychart.wyse \
	doc/jove.rc.xterm doc/keychart.xterm \
	doc/jove.rc.xterm-256color doc/keychart.xterm-256color \
	doc/jove.rc.z29 doc/keychart.z29 \
	doc/jove.rc.3022 doc/keychart.3022 \
	doc/keychart. \
	doc/XTermresource

CDOC = doc/cmds.doc

# formatted docs, we ship these in the distrib to avoid groff dependency
# and for non-Unix/Linux platforms.  NOTE: These will be removed by clobber.
# Also note that jove.man and jove.man.ps require the ms macros
# (tmac.s or s.tmac) which many systems do not install with base groff.
FDOCS = $(CDOC) doc/jove.man doc/jove.man.ps doc/jove.doc

# files we generate that we also ship in distrib for platforms sans sed
# NOTE: these will be removed by clobber.
GEN = 	doc/jove.rc doc/jove.$(MANEXT) \
	doc/teachjove.$(MANEXT) doc/jovetool.$(MANEXT)

DOSDOCS =  doc/README doc/teach-jove doc/jove.qref doc/example.rc doc/jem.txt

DOCS =  doc/intro.nr doc/cmds.macros.nr doc/cmds.nr doc/contents.nr \
	doc/jove.nr doc/teachjove.nr doc/xjove.nr doc/jovetool.nr \
	doc/jove.rc.in $(DOSDOCS) $(DOCTERMS) $(FDOCS) $(GEN)

MISC =	Makefile Makefile.msc Makefile.wat \
	README README.dos README.win ChangeLog LICENSE \
	sysdep.doc tune.doc style.doc jmake.sh \
	testbuild.sh testmailer.sh

SUPPORT = recover.c setmaps.c portsrv.c keys.txt \
	menumaps.txt mjovers.Hqx jjove.ico jjove.rc teachjove

BACKUPS = $(HEADERS) $(C_SRC) $(SUPPORT) $(MISC)

# all: default target.
# Builds everything that "install" needs.
all:	jjove$(XEXT) recover$(XEXT) portsrv$(XEXT) $(CDOC) $(GEN)

jjove$(XEXT):	$(OBJECTS) $(EXTRAOBJS) $(ICON)
	$(LDCC) $(LDFLAGS) $(CFLAGS) -o jjove$(XEXT) $(OBJECTS) $(EXTRAOBJS) $(ICON) $(LDLIBS)
	@-size jjove$(XEXT)

# For mingw icon
jjove.coff: jjove.rc version.h
	$(WINDRES) -r jjove.rc -fo jjove.coff

# For 2.xBSD: link jove as a set of overlays.  Not tested recently.

ovjove:	$(OBJECTS)
	ld $(LDFLAGS) $(OPTFLAGS) -X /lib/crt0.o \
		-Z $(OVLAY1) \
		-Z $(OVLAY2) \
		-Z $(OVLAY3) \
		-Z $(OVLAY4) \
		-Z $(OVLAY5) \
		-Y $(BASESEG) \
		-o jjove$(XEXT) $(EXTRALIBS) $(TERMCAPLIB) -lc
	@-size jjove$(XEXT)

# portsrv is only needed if IPROCS are implemented using PIPEPROCS
# (modern systems use PTYPROCS).
# Making PORTSRVINST null suppresses installing portsrv.

# PORTSRVINST=$(PORTSRV)
PORTSRVINST=

portsrv$(XEXT):	portsrv.o
	$(LDCC) $(LDFLAGS) $(CFLAGS) -o portsrv$(XEXT) portsrv.o $(LDLIBS)

recover$(XEXT):	recover.o
	$(LDCC) $(LDFLAGS) $(CFLAGS) -o recover$(XEXT) recover.o $(LDLIBS)

# no need to optimize setmaps since it is run once during build, so faster
# compile is better than faster executable (also urban legend that 
# optimization produced bad code for setmaps!)
setmaps$(LOCALEXT):	setmaps.o
	$(LOCALCC) $(LOCALLDFLAGS) $(LOCALCFLAGS)-o setmaps$(LOCALEXT) setmaps.o $(LOCALEXTRALIBS)

# Critical that setmaps be compiled with same SYSDEFS
setmaps.o:	setmaps.c
	$(LOCALCC) $(LOCALCFLAGS) $(SYSDEFS) -c setmaps.c

# create a temporary directory to hold some temporary intermediate files that the
# Makefile generates, as a precaution against security hole via races (mktemp would be 
# better, but we try to keep this Makefile working on old Unix, pre-POSIX, sigh)
TDIR=$(JTMPDIR)/jbuild$$$$
TFILE=$(TDIR)/temp

keys.c:	setmaps$(LOCALEXT) keys.txt Makefile .ALWAYS
	@mkdir $(TDIR) && \
	./setmaps$(LOCALEXT) < keys.txt > $(TFILE) && \
	echo 'char JoveCompiled[sizeof(JoveCompiled)] = "'$(CC) $(CFLAGS)'";' >> $(TFILE) && \
	echo 'char JoveLinked[sizeof(JoveLinked)] = "'$(LDCC) $(LDFLAGS) $(CFLAGS) $(EXTRAOBJS) $(LDLIBS)'";' >> $(TFILE) && \
	if ! $(CMP) -s $(TFILE) keys.c 2> /dev/null; then mv $(TFILE) keys.c; else rm $(TFILE); fi; rmdir $(TDIR)

keys.o:	keys.c tune.h sysdep.h jove.h keymaps.h dataobj.h commands.h

.ALWAYS:

# BSD sed cannot handle \t, and having tabs in the whitespace feels fragile.
.version: .ALWAYS
	@mkdir $(TDIR) && \
	sed -n 's/# *define  *jversion  *"\([0-9\\.]*\)".*/\1/p' version.h > $(TFILE); \
	if ! $(CMP) -s $(TFILE) .version 2> /dev/null; then mv $(TFILE) .version; else rm $(TFILE); fi; rmdir $(TDIR)

jove.spec: .version
	@mkdir $(TDIR) && \
	v=`sed 's/_.*//' .version`; sed "s,__VERSION__,$$v,g" pkg/rpm/jspec.in > $(TFILE); \
	if ! $(CMP) -s $(TFILE) jove.spec 2> /dev/null; then mv $(TFILE) jove.spec; else rm $(TFILE); fi; rmdir $(TDIR)

paths.h: .ALWAYS
	@mkdir $(TDIR) && \
	(echo "/* Changes should be made in Makefile, not to this file! */" ; \
	echo ""; \
	echo \#define TMPDIR \"$(JTMPDIR)\"; \
	echo \#define RECDIR \"$(JRECDIR)\"; \
	echo \#define LIBDIR \"$(JLIBDIR)\"; \
	echo \#define SHAREDIR \"$(JSHAREDIR)\"; \
	echo \#define TEACHJOVE \"$(JTEACHBASE)\"; \
	echo \#define DFLTSHELL \"$(DFLTSHELL)\";) > $(TFILE); \
	if ! $(CMP) -s $(TFILE) paths.h 2> /dev/null; then mv $(TFILE) paths.h; else rm $(TFILE); fi; rmdir $(TDIR)

makexjove:
	( cd xjove ; make CC="$(CC)" OPTFLAGS="$(OPTFLAGS)" SYSDEFS="$(SYSDEFS)" $(TOOLMAKEEXTRAS) xjove )

installxjove:  $(XJOVEM)
	( cd xjove ; make CC="$(CC)" OPTFLAGS="$(OPTFLAGS)" SYSDEFS="$(SYSDEFS)" XINSTALL="$(XINSTALL)" BINDIR="$(DBINDIR)" INSTALLFLAGS="$(INSTALLFLAGS)" $(TOOLMAKEEXTRAS) installxjove )

makejovetool:
	( cd xjove ; make CC="$(CC)" OPTFLAGS="$(OPTFLAGS)" SYSDEFS="$(SYSDEFS)" DEFINES=-DSUNVIEW $(TOOLMAKEEXTRAS) jovetool )

installjovetool: $(JOVETOOLM)
	( cd xjove ; make CC="$(CC)" OPTFLAGS="$(OPTFLAGS)" SYSDEFS="$(SYSDEFS)" DEFINES=-DSUNVIEW XINSTALL="$(XINSTALL)" BINDIR="$(DBINDIR)" INSTALLFLAGS="$(INSTALLFLAGS)" $(TOOLMAKEEXTRAS) installjovetool )

# Note: everything needed by "install" should be built by "all".
# Thus, if "all" is done first, "install" can be invoked with
# JOVEHOME pointing at a playpen where files are to be marshalled.
# This property is fragile.
install: $(DRECDIR) $(DETCDIR) \
	$(TEACHJOVEDOC) $(CMDSDOC) $(TERMSDIR)/keychart. $(JOVERC) \
	$(PORTSRVINST) $(RECOVER) $(JOVE) $(TEACHJOVE) $(MANUALS)
	@echo See the README about changes to /etc/rc or /etc/rc.local
	@echo so that the system recovers jove files on reboot after a crash

$(DBINDIR)::
	if test ! -e $(DBINDIR); then mkdir -p $(DBINDIR) && chmod $(DPERM) $(DBINDIR); fi

$(DLIBDIR)::
	if test ! -e $(DLIBDIR); then mkdir -p $(DLIBDIR) && chmod $(DPERM) $(DLIBDIR); fi

$(DSHAREDIR)::
	if test ! -e $(DSHAREDIR); then mkdir -p $(DSHAREDIR) && chmod $(DPERM) $(DSHAREDIR); fi

$(DETCDIR)::
	-if test ! -e $(DETCDIR); then mkdir -p $(DETCDIR) && chmod $(DPERM) $(DETCDIR); fi

$(DMANDIR)::
	if test ! -e $(DMANDIR); then mkdir -p $(DMANDIR) && chmod $(DPERM) $(DMANDIR); fi

$(DRECDIR)::
	-if test ! -e $(DRECDIR); then mkdir -p $(DRECDIR) && chmod $(RECPERM) $(DRECDIR); fi

# first run of rpmbuild will mkdir other sibling directories in RPMHOME, but 
# we need this before we run rpmbuild, so RPMHOME might not even exist.
$(RPMHOME)::
	if test ! -e $(RPMHOME); then mkdir -p $(RPMHOME) && chmod $(DPERM) $(RPMHOME); fi

$(TEACHJOVEDOC): $(DSHAREDIR) doc/teach-jove
	$(TINSTALL) doc/teach-jove doc/jove.qref $(DSHAREDIR)

doc/cmds.doc:	doc/cmds.macros.nr doc/cmds.nr
	@mkdir $(TDIR) && \
	LANG=C $(NROFF) doc/cmds.macros.nr doc/cmds.nr > $(TFILE); \
	if ! $(CMP) -s $(TFILE) doc/cmds.doc 2> /dev/null; then mv $(TFILE) doc/cmds.doc; else rm $(TFILE); fi; rmdir $(TDIR)

doc/jove.man:	doc/intro.nr doc/cmds.nr
	@mkdir $(TDIR) && \
	LANG=C; export LANG; cd doc && tbl intro.nr | $(NROFF) -ms - cmds.nr > $(TFILE); \
	if ! $(CMP) -s $(TFILE) jove.man 2> /dev/null; then mv $(TFILE) jove.man; else rm $(TFILE); fi; rmdir $(TDIR)

doc/jove.man.ps: doc/intro.nr doc/cmds.nr doc/contents.nr
	@mkdir $(TDIR) && \
	LANG=C; export LANG; cd doc && tbl intro.nr | $(TROFF) -ms - cmds.nr contents.nr $(TROFFPOST) > $(TFILE); \
	if ! $(CMP) -s $(TFILE) jove.man.ps 2> /dev/null; then mv $(TFILE) jove.man.ps; else rm $(TFILE); fi; rmdir $(TDIR)

$(CMDSDOC): $(DSHAREDIR) $(CDOC)
	$(TINSTALL) $(CDOC) $(CMDSDOC)

doc/jove.rc: doc/jove.rc.in
	@mkdir $(TDIR) && \
	sed "s,__ETCDIR__,$(JETCDIR)," doc/jove.rc.in > $(TFILE); \
	if ! $(CMP) -s $(TFILE) doc/jove.rc 2> /dev/null; then mv $(TFILE) doc/jove.rc; else rm $(TFILE); fi; rmdir $(TDIR)

$(JOVERC): $(DSHAREDIR) doc/jove.rc
	$(TINSTALL) doc/jove.rc doc/jem* $(DSHAREDIR)

$(TERMSDIR)/keychart.: $(TERMSDIR) $(DOCTERMS)
	$(TINSTALL) $(DOCTERMS) $(TERMSDIR)

$(PORTSRV): $(DLIBDIR) portsrv$(XEXT)
	$(XINSTALL) portsrv$(XEXT) $(PORTSRV)

$(RECOVER): $(DLIBDIR) recover$(XEXT)
	$(XINSTALL) recover$(XEXT) $(RECOVER)

$(JOVE): $(DBINDIR) jjove$(XEXT)
	$(XINSTALL) jjove$(XEXT) $(JOVE)

$(TEACHJOVE): $(DBINDIR)
	$(XINSTALL) teachjove $(TEACHJOVE)

doc/jove.$(MANEXT): doc/jove.nr
	@mkdir $(TDIR) && \
	sed -e 's;<TMPDIR>;$(JTMPDIR);' \
	     -e 's;<LIBDIR>;$(JLIBDIR);' \
	     -e 's;<SHAREDIR>;$(JSHAREDIR);' \
	     -e 's;<SHELL>;$(DFLTSHELL);' doc/jove.nr > $(TFILE); \
	if ! $(CMP) -s $(TFILE) doc/jove.$(MANEXT) 2> /dev/null; then mv $(TFILE) doc/jove.$(MANEXT); else rm $(TFILE); fi; rmdir $(TDIR)

$(JOVEM): $(DMANDIR) doc/jove.$(MANEXT)
	$(TINSTALL) doc/jove.$(MANEXT) $(JOVEM)

# doc/jove.doc is the formatted manpage (only needed by DOS)
# Building it should be like building $(JOVEM) except that we
# don't know what to substitute for <TMPDIR> etc. because they
# are not fixed yet, and because we must do the formatting.

doc/jove.doc: doc/jove.nr
	@mkdir $(TDIR) && \
	LANG=C $(NROFF) -man doc/jove.nr > $(TFILE) && \
	if ! $(CMP) -s $(TFILE) doc/jove.doc 2> /dev/null; then mv $(TFILE) doc/jove.doc; else rm $(TFILE); fi; rmdir $(TDIR)

doc/teachjove.$(MANEXT): doc/teachjove.nr
	@mkdir $(TDIR) && \
	sed -e 's;<TMPDIR>;$(JTMPDIR);' \
	     -e 's;<LIBDIR>;$(JLIBDIR);' \
	     -e 's;<SHAREDIR>;$(JSHAREDIR);' \
	     -e 's;<SHELL>;$(DFLTSHELL);' doc/teachjove.nr > $(TFILE); \
	if ! $(CMP) -s $(TFILE) doc/teachjove.$(MANTXT) 2> /dev/null; then mv $(TFILE) doc/teachjove.$(MANEXT); else rm $(TFILE); fi; rmdir $(TDIR)

$(TEACHJOVEM): $(DMANDIR) doc/teachjove.$(MANEXT)
	$(TINSTALL) doc/teachjove.$(MANEXT) $(TEACHJOVEM)

$(XJOVEM): $(DMANDIR) doc/xjove.nr
	$(TINSTALL) doc/xjove.nr $(XJOVEM)

doc/jovetool.$(MANEXT): doc/jovetool.nr
	@mkdir $(TDIR) && \
	sed -e 's;<MANDIR>;$(MANDIR);' \
	     -e 's;<MANEXT>;$(MANEXT);' doc/jovetool.nr > $(TFILE); \
	if ! $(CMP) -s $(TFILE) doc/jovetool.$(MANTXT) 2> /dev/null; then mv $(TFILE) doc/jovetool.$(MANEXT); else rm $(TFILE); fi; rmdir $(TDIR)

$(JOVETOOLM): $(DMANDIR) doc/jovetool.$(MANEXT)
	$(TINSTALL) doc/jovetool.$(MANEXT) $(JOVETOOLM)

fdocs: $(FDOCS)

echo:
	@echo $(SOURCES) $(HEADERS)

# note: $(C_SRC) contains commands.tab and vars.tab
# These should not be linted, but they will probably be ignored.

lint: keys.c
	lint $(SYSDEFS) $(C_SRC) keys.c
	lint $(SYSDEFS) portsrv.c
	lint $(SYSDEFS) recover.c
	lint $(SYSDEFS) setmaps.c
	@echo Done

# CTAGSFLAGS = -N --format=1 # fishy options required for Exuberant Ctags
# since this is inconvenient to specify, you can use target extags instead.
CTAGSFLAGS = -w

tags:	$(C_SRC) $(HEADERS)
	-ctags $(CTAGSFLAGS) $(C_SRC) $(HEADERS)

extags:	$(C_SRC) $(HEADERS)
	-ctags -N --format=1 $(C_SRC) $(HEADERS)


# .filelist is a trick to get around a make limit:
# the list of files is too long to fit in a command generated by make
# The actual contents of the file depend only on Makefile, but by
# adding extra dependencies, dependants of .filelist can have shorter
# dependency lists.  Note: since we have no list of xjove files,
# we alway force a make of xjove/.filelist.  This forces .filelist
# to be rebuilt every time it is needed.

.filelist:	$(BACKUPS) $(DOCS) tags
	@mkdir $(TDIR) && \
	if test -f tags; then ls tags; fi > $(TFILE) && \
	ls $(BACKUPS) >> $(TFILE) && \
	    ls $(DOCS) >> $(TFILE) && \
	    find pkg old -print >> $(TFILE) && \
	    (cd xjove ; make FLIST=$(TFILE).xj $(TFILE).xj) && \
	    sed -e 's=^=xjove/=' $(TFILE).xj >> $(TFILE); \
	if ! $(CMP) -s $(TFILE) .filelist 2> /dev/null; then mv $(TFILE) .filelist; else rm $(TFILE); fi; rm -f $(TFILE).xj; rmdir $(TDIR)

# Build a distribution: a gzipped tar file with a name "jove-<version>.tgz"
# The tar will unpack into a directory with the name jove-<version>
# Beware: old files with these names will be blown away.
tgz:	.version .filelist Makefile jove.spec
	set -u ; set -e ; \
	BN=jove-`cat .version` ; \
	rm -rf $$BN $$BN.tgz* ; \
	mkdir $$BN ; \
	$(TAR) cf - jove.spec `cat .filelist` | ( cd $$BN ; $(TAR) xf - ) ; \
	$(TAR) czf $$BN.tgz $$BN ; \
	rm -rf $$BN ; \
	ls -l $$BN.tgz

distrib: tgz zip

rpm: jove.spec .version tgz $(RPMHOME)
	# rpmbuild really wants the source tarball to have
	# the basename of Source0 in the rpm spec, and be
	# in the rpmbuild SOURCES directory.
	rpmsrc=`sed -n '/Source0/s,.*/,,p' jove.spec`; \
	BN=jove-`cat .version` ; \
	cp $$BN.tgz $(RPMHOME)/$$rpmsrc; \
	rpmbuild -ta $(RPMHOME)/$$rpmsrc

# requires pbuilder to be installed, which uses chroot so needs to be run as root.
deb: .version tgz
	BN=`pwd`/jove-`cat .version`.tgz && cd pkg/deb && ./testdeb.sh $$BN

# create a distribution and a separate GPG signature for it
signed:	.version tgz
	BN=jove-`cat .version` ; \
	gpg -sba $$BN.tgz; \
	chmod a+r $$BN.tgz.asc

# MSDOS isn't a full-fledged development environment.
# Preparing a distribution for MSDOS involves discarding some things
# and pre-building others.  All should have \n converted to CR LF.
# From SUPPORT: setmaps.c, keys.txt, recover.c
# From MISC: all but Makefile and README.mac
# Preformatted documentation. [would like a joverc]
# tags

DOSSRC = $(HEADERS) $(C_SRC) setmaps.c recover.c keys.txt \
	Makefile.msc Makefile.wat ChangeLog \
	README README.dos README.win sysdep.doc tune.doc style.doc \
	jjove.rc $(FDOCS) tags doc/jove.rc $(DOSDOCS)

zip:	.version $(DOSSRC) jjove.ico Makefile
	set -u ; set -e ; \
        V=`sed 's/\.//g;s/^\(...\).*/\1/' .version` && \
	BN=jove$${V}s && \
	rm -rf $$BN && \
	mkdir $$BN && \
	$(TAR) cf - jjove.ico $(DOSSRC) | ( cd $$BN ; $(TAR) xf - ) && \
	$(ZIP) $(ZIPOPTS) jovetmp$$$$.$(ZIPEXT) $$BN/jjove.ico && \
	rm -f $$BN/jjove.ico && \
	mv $$BN/doc/jove.man.ps $$BN/doc/joveman.ps && \
	mv $$BN/doc/teach-jove $$BN/doc/teachjov.txt && \
	mv $$BN/ChangeLog $$BN/changelg.txt && \
	$(ZIP) $(ZIPOPTS) jovetmp$$$$.$(ZIPEXT) $(ZIPTXTOPT) $$BN/* && \
	rm -f jove$${V}s.$(ZIPEXT) && \
	mv jovetmp$$$$.$(ZIPEXT) jove$${V}s.$(ZIPEXT) && \
	rm -rf $$BN ; \
	ls -l jove$${V}s.$(ZIPEXT)

touch:
	touch $(OBJECTS)

clean:
	rm -f a.out core *.o keys.c jjove$(XEXT) portsrv$(XEXT) recover$(XEXT) \
		setmaps$(XEXT) make.log *.map \#* *~ *.tmp \
		jjove.pure_* ID *.exe jjove.coff */*.tmp \
		.filelist xjove/.filelist .version

cleanall: clean
	( cd xjove ; make clean )

# NOTE: deletes distrib
clobber: cleanall
	rm -f paths.h $(FDOCS) $(GEN) tags *.tgz *.$(ZIPEXT) *.orig *.rej

# This version only works under 4.3BSD
dependbsd:
	@echo '"make depend" only works under 4.3BSD'
	@-rm -f Makefile.new
	sed -e '/^# DO NOT DELETE THIS LINE/q' Makefile >Makefile.new
	for i in ${SOURCES} ; do \
		$(CC) ${CFLAGS} ${DEPENDFLAG} $$i | \
		awk ' /[/]usr[/]include/ { next } \
			{ if ($$1 != prev) \
		    { if (rec != "") print rec; rec = $$0; prev = $$1; } \
		    else { if (length(rec $$2) > 78) { print rec; rec = $$0; } \
		    else rec = rec " " $$2 } } \
		    END { print rec } ' >>Makefile.new; \
	done
	echo '# DEPENDENCIES MUST END AT END OF FILE' >>Makefile.new
	echo '# IF YOU PUT STUFF HERE IT WILL GO AWAY' >>Makefile.new
	echo '# see "make depend" above' >>Makefile.new
	@echo 'New makefile is in "Makefile.new".  Move it to "Makefile".'

# This version should work with any UNIX
# It records all dependencies, including ones that are #ifdef'ed out.
# It assumes that only jove.h and tune.h include other headers

depend:
	@sed -e '/^# DO NOT DELETE THIS LINE/q' Makefile >Makefile.new
	for i in tune.h jove.h ${SOURCES} ; do \
		( ( echo "$$i:"; sed -n -e 's/^#[ 	]*include[ 	]*"\([^"]*\)".*/\1/p' $$i ) | \
		sed -e 's/^jove\.h$$/$$(JOVE_H)/' -e 's/^tune\.h$$/$$(TUNE_H)/' \
			-e 's/^jove\.h:$$/JOVE_H = jove.h/' -e 's/^tune\.h:$$/TUNE_H = tune.h/' \
			-e 's/\.c:$$/.o:/' | \
		tr "\012" "\040" ; echo ) | sed -e 's/ $$//' -e '/:$$/d' >>Makefile.new ; \
	done
	@echo '# DEPENDENCIES MUST END AT END OF FILE' >>Makefile.new
	@echo '# IF YOU PUT STUFF HERE IT WILL GO AWAY' >>Makefile.new
	@echo '# see "make depend" above' >>Makefile.new
	@if $(CMP) -s Makefile Makefile.new 2> /dev/null; \
		then echo '*** Makefile is already up to date' ; rm -f Makefile.new; \
		else echo '*** New makefile is in "Makefile.new".  Move it to "Makefile".' ; \
	fi

# DO NOT DELETE THIS LINE -- "make depend" uses it
TUNE_H = tune.h sysdep.h
JOVE_H = jove.h $(TUNE_H) buf.h io.h dataobj.h keymaps.h argcount.h util.h externs.h
commands.o: $(JOVE_H) jctype.h extend.h macros.h mouse.h abbrev.h c.h case.h commands.h delete.h disp.h insert.h sysprocs.h iproc.h marks.h misc.h move.h para.h proc.h reapp.h wind.h commands.tab
abbrev.o: $(JOVE_H) fp.h jctype.h abbrev.h ask.h commands.h delete.h insert.h disp.h fmt.h move.h wind.h
argcount.o: $(JOVE_H) jctype.h
ask.o: $(JOVE_H) jctype.h chars.h disp.h fp.h scandir.h screen.h ask.h delete.h insert.h extend.h fmt.h marks.h move.h wind.h mac.h
buf.o: $(JOVE_H) jctype.h disp.h ask.h extend.h fmt.h insert.h macros.h marks.h move.h sysprocs.h proc.h wind.h fp.h iproc.h mac.h
c.o: $(JOVE_H) re.h c.h jctype.h disp.h delete.h insert.h fmt.h marks.h misc.h move.h para.h
case.o: $(JOVE_H) disp.h case.h jctype.h marks.h move.h
jctype.o: $(JOVE_H) jctype.h
delete.o: $(JOVE_H) jctype.h disp.h delete.h insert.h marks.h move.h
disp.o: $(JOVE_H) jctype.h chars.h fp.h disp.h ask.h extend.h fmt.h insert.h sysprocs.h iproc.h move.h macros.h screen.h term.h wind.h mac.h
extend.o: $(JOVE_H) fp.h jctype.h chars.h commands.h disp.h re.h ask.h extend.h fmt.h insert.h move.h sysprocs.h proc.h vars.h mac.h
fp.o: $(JOVE_H) fp.h jctype.h disp.h fmt.h mac.h
fmt.o: $(JOVE_H) chars.h fp.h jctype.h disp.h extend.h fmt.h mac.h
insert.o: $(JOVE_H) jctype.h list.h chars.h disp.h abbrev.h ask.h c.h delete.h insert.h fmt.h macros.h marks.h misc.h move.h para.h screen.h sysprocs.h proc.h wind.h re.h
io.o: $(JOVE_H) list.h fp.h jctype.h disp.h ask.h fmt.h insert.h marks.h sysprocs.h proc.h wind.h rec.h mac.h re.h temp.h
iproc.o: $(JOVE_H) re.h jctype.h disp.h fp.h sysprocs.h iproc.h ask.h extend.h fmt.h insert.h marks.h move.h proc.h wind.h ttystate.h select.h
jove.o: $(JOVE_H) fp.h jctype.h chars.h disp.h re.h reapp.h sysprocs.h rec.h ask.h extend.h fmt.h macros.h marks.h mouse.h paths.h proc.h screen.h term.h version.h wind.h iproc.h select.h mac.h
jtc.o: $(JOVE_H) jctype.h fmt.h fp.h select.h
list.o: $(JOVE_H) list.h
macros.o: $(JOVE_H) jctype.h fp.h chars.h disp.h ask.h commands.h macros.h extend.h fmt.h
marks.o: $(JOVE_H) fmt.h marks.h disp.h
misc.o: $(JOVE_H) jctype.h disp.h ask.h c.h delete.h insert.h extend.h fmt.h marks.h misc.h move.h para.h
move.o: $(JOVE_H) re.h chars.h jctype.h disp.h move.h screen.h
para.o: $(JOVE_H) jctype.h disp.h delete.h insert.h fmt.h marks.h misc.h move.h para.h re.h
proc.o: $(JOVE_H) jctype.h fp.h re.h disp.h sysprocs.h ask.h delete.h extend.h fmt.h insert.h iproc.h marks.h misc.h move.h proc.h wind.h
re.o: $(JOVE_H) re.h jctype.h ask.h disp.h fmt.h marks.h
reapp.o: $(JOVE_H) fp.h re.h jctype.h chars.h disp.h ask.h extend.h fmt.h marks.h reapp.h wind.h mac.h
rec.o: $(JOVE_H) fp.h sysprocs.h rec.h fmt.h recover.h
scandir.o: $(JOVE_H) scandir.h
screen.o: $(JOVE_H) fp.h chars.h jctype.h disp.h extend.h fmt.h term.h mac.h screen.h wind.h
term.o: $(JOVE_H) term.h fp.h
termcap.o: $(JOVE_H) term.h disp.h fmt.h fp.h jctype.h screen.h
unix.o: $(JOVE_H) fp.h chars.h term.h ttystate.h
util.o: $(JOVE_H) jctype.h disp.h fp.h ask.h chars.h fmt.h insert.h macros.h marks.h move.h rec.h mac.h
vars.o: $(JOVE_H) extend.h vars.h abbrev.h ask.h c.h jctype.h disp.h insert.h sysprocs.h iproc.h mac.h mouse.h para.h proc.h re.h reapp.h rec.h screen.h term.h ttystate.h wind.h vars.tab
wind.o: $(JOVE_H) chars.h disp.h ask.h extend.h commands.h mac.h reapp.h wind.h screen.h
msgetch.o: $(JOVE_H) chars.h disp.h
mac.o: $(TUNE_H) $(JOVE_H) mac.h ask.h chars.h disp.h extend.h fp.h commands.h fmt.h marks.h misc.h move.h screen.h scandir.h term.h vars.h version.h wind.h
keymaps.o: $(JOVE_H) list.h fp.h jctype.h chars.h disp.h re.h ask.h commands.h macros.h extend.h fmt.h screen.h vars.h sysprocs.h iproc.h
ibmpcdos.o: $(JOVE_H) fp.h chars.h screen.h term.h
mouse.o: $(JOVE_H) commands.h disp.h misc.h ask.h chars.h delete.h fmt.h insert.h marks.h move.h wind.h term.h fp.h jctype.h mouse.h xjove/mousemsg.h
win32.o: $(JOVE_H) fp.h chars.h screen.h disp.h
portsrv.o: $(JOVE_H) sysprocs.h iproc.h
recover.o: $(JOVE_H) sysprocs.h rec.h paths.h recover.h scandir.c jctype.h
setmaps.o: $(JOVE_H) chars.h commands.h vars.h commands.tab vars.tab
# DEPENDENCIES MUST END AT END OF FILE
# IF YOU PUT STUFF HERE IT WILL GO AWAY
# see "make depend" above
