/***************************************************************************
 * This program is Copyright (C) 1986, 1987, 1988 by Jonathan Payne.  JOVE *
 * is provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is    *
 * included in all the files.                                              *
 ***************************************************************************/

extern void	jputchar proto((int c));	/* hidden by macro */

#define jputchar(c)	jputc((c), stdout)
#define jputc(c, fp)	{ while (--(fp)->f_cnt < 0) flushout(fp); *(fp)->f_ptr++ = (c); }
#define jgetc(fp)	\
	(((--(fp)->f_cnt < 0) ? filbuf(fp) : (unsigned char) *(fp)->f_ptr++))
#define f_eof(fp)	((fp)->f_flags & F_EOF)

/* typedef struct FileStruct File in jove.h */

struct FileStruct {
	int	f_cnt,		/* number of characters left in buffer */
		f_bufsize,	/* size of what f_base points to */
		f_fd,		/* fildes */
		f_flags;	/* various flags */
	char	*f_ptr,		/* current offset */
		*f_base;	/* pointer to base */
	char	*f_name;	/* name of open file */
};

#define F_READ		01
#define F_WRITE		02
#define F_APPEND	04
#define F_MODE(x)	((x)&07)
#define F_EOF		010
#define F_STRING	020
#define F_ERR		040
#define F_LOCKED	0100	/* don't close this file upon error */
#define F_MYBUF		0200	/* f_alloc allocated the buffer, so
				   f_close knows to free it up */
#define F_TELLALL	0400	/* whether to display info upon close */
#define F_READONLY	01000	/* file is read only */

extern File
	*stdout;

#ifndef	SMALL
# define MAXTTYBUF	2048
#else
# define MAXTTYBUF	512
#endif

extern int	BufSize;

extern File
	*f_open proto((char *name,int flags,char *buffer,int buf_size)),
	*fd_open proto((char *name,int flags,int fd,char *buffer,int bsize));

extern int
	filbuf proto((File *fp));

#if	defined(IPROCS) && defined(PIPEPROCS)
extern size_t
	f_readn proto((File *fp,char *addr,size_t n));
#endif

#ifdef	ZORTECH
typedef long	off_t;
#endif

extern void
	f_close proto((File *fp)),
	f_seek proto((File *fp, off_t offset)),
	f_toNL proto((File *fp)),
	flushout proto((File *fp)),
	flushscreen proto((void)),
	fputnchar proto((char *s,int n,File *fp)),
	gc_openfiles proto((void)),
	putstr proto((char *s));

extern bool
	f_gets proto((File *fp,char *buf,size_t max));
