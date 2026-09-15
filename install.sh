#!/bin/sh
set -eu

# Installation locations; override them when invoking the script.
PREFIX=${PREFIX:-/usr/local}
BINDIR=${BINDIR:-"$PREFIX/bin"}
DATADIR=${DATADIR:-"$PREFIX/share"}
MANDIR=${MANDIR:-"$DATADIR/man"}

# Staging directory, useful for packages.
DESTDIR=${DESTDIR:-}

# Project files.
PROGRAM=${PROGRAM:-gdoc}
BINARY=${BINARY:-"./$PROGRAM"}

# Man pages. Leave entries empty or remove them if not applicable.
MAN1=${MAN1:-"$PROGRAM.1"}
MAN5=${MAN5:-"$PROGRAM.5"}
MAN7=${MAN7:-}

# File modes.
BINMODE=${BINMODE:-755}
MANMODE=${MANMODE:-644}

usage()
{
    cat <<EOF
Usage: $0 [OPTIONS]

Install $PROGRAM and its manual pages.

Options:
  -h, --help    Show this help message and exit

Environment variables:
  PREFIX        Installation prefix       [default: /usr/local]
  BINDIR        Binary installation dir   [default: \$PREFIX/bin]
  DATADIR       Shared data directory     [default: \$PREFIX/share]
  MANDIR        Manual page directory     [default: \$DATADIR/man]

  PROGRAM       Program name              [default: gdoc]
  BINARY        Binary to install         [default: ./$PROGRAM]

  MAN1          Section 1 man page        [default: $PROGRAM.1]
  MAN5          Section 5 man page        [default: $PROGRAM.5]

  BINMODE       Installed binary mode     [default: 755]
  MANMODE       Installed man page mode   [default: 644]

Examples:
  sudo $0
  PREFIX=\$HOME/.local $0
  DESTDIR=\$PWD/pkg PREFIX=/usr $0
EOF
}

# Handle command-line options.
case ${1:-} in
    -h|--help)
        usage
        exit 0
        ;;
    "")
        ;;
    *)
        echo "error: unknown option: $1" >&2
        echo "Try '$0 --help' for more information." >&2
        exit 1
        ;;
esac

install_dir()
{
    install -d "$DESTDIR$1"
}

install_file()
{
    src=$1
    dst=$2
    mode=$3

    if [ ! -f "$src" ]; then
        echo "error: file not found: $src" >&2
        exit 1
    fi

    install -m "$mode" "$src" "$DESTDIR$dst"
}

echo "Installing $PROGRAM"
echo "  prefix: $PREFIX"

install_dir "$BINDIR"
install_file "$BINARY" "$BINDIR/$PROGRAM" "$BINMODE"

if [ -n "$MAN1" ]; then
    install_dir "$MANDIR/man1"
    install_file "$MAN1" "$MANDIR/man1/$PROGRAM.1" "$MANMODE"
fi

if [ -n "$MAN5" ]; then
    install_dir "$MANDIR/man5"
    install_file "$MAN5" "$MANDIR/man5/$(basename "$MAN5")" "$MANMODE"
fi

if [ -n "$MAN7" ]; then
    install_dir "$MANDIR/man7"
    install_file "$MAN7" "$MANDIR/man7/$(basename "$MAN7")" "$MANMODE"
fi

echo "Installation complete."

