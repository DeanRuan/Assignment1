
#!/bin/bash

# Script information
# Created by Lubos Kuzma
# ISS Program, SADT, SAIT
# August 2022
# Edited By Brian Dang
# Default setting to x64 Architecture
# Added comments explaining each section of the script to enhance readability and understanding.
# Try to add an <Install> option but it seem to not recognize -i.

# Check if there are not enough arguments provided
#!/bin/bash

# edited by Yukun Ruan

if [ $# -lt 1 ]; then
    echo "Usage:"
    echo ""
    echo "x86_toolchain.sh [ options ] <assembly filename> [-o | --output <output filename>] [-l | --library <library name>]"
    echo ""
    echo "-v | --verbose                Show some information about steps performed."
    echo "-g | --gdb                    Run gdb command on executable."
    echo "-b | --break <break point>    Add breakpoint after running gdb. Default is _start."
    echo "-r | --run                    Run program in gdb automatically. Same as run command inside gdb env."
    echo "-q | --qemu                   Run executable in QEMU emulator. This will execute the program."
    echo "-64| --x86-64                 Compile for 64bit (x86-64) system."
    echo "-o | --output <filename>      Output filename."
    echo "-l | --library <library name>  Link external library."
    exit 1
fi
 
POSITIONAL_ARGS=()
GDB=False
OUTPUT_FILE=""
VERBOSE=False
BITS=False
QEMU=False
BREAK="_start"
RUN=False
LIBRARY=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--gdb)
            GDB=True
            shift # past argument
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift # past argument
            shift # past value
            ;;
        -v|--verbose)
            VERBOSE=True
            shift # past argument
            ;;
        -64|--x86-64)
            BITS=True
            shift # past argument
            ;;
        -q|--qemu)
            QEMU=True
            shift # past argument
            ;;
        -r|--run)
            RUN=True
            shift # past argument
            ;;
        -b|--break)
            BREAK="$2"
            shift # past argument
            shift # past value
            ;;
        -l|--library)
            LIBRARY="$2"
            shift # past argument
            shift # past value
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done
 
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters
 
if [[ ! -f $1 ]]; then
    echo "Specified file does not exist"
    exit 1
fi
 
if [ "$OUTPUT_FILE" == "" ]; then
    OUTPUT_FILE=${1%.*}
fi
 
if [ "$VERBOSE" == "True" ]; then
    echo "Arguments being set:"
    echo "    GDB = ${GDB}"
    echo "    RUN = ${RUN}"
    echo "    BREAK = ${BREAK}"
    echo "    QEMU = ${QEMU}"
    echo "    Input File = $1"
    echo "    Output File = $OUTPUT_FILE"
    echo "    Verbose = $VERBOSE"
    echo "    64 bit mode = $BITS" 
    echo "    Library = $LIBRARY"
    echo ""
    echo "NASM started..."
fi
 
if [ "$BITS" == "True" ]; then
    nasm -f elf64 $1 -o $OUTPUT_FILE.o && echo ""
else
    nasm -f elf $1 -o $OUTPUT_FILE.o && echo ""
fi
 
if [ "$VERBOSE" == "True" ]; then
    echo "NASM finished"
    echo "Linking ..."
fi
 
if [ "$BITS" == "True" ]; then
    gcc -m64 -o $OUTPUT_FILE $OUTPUT_FILE.o $LIBRARY && echo ""
else
    gcc -o $OUTPUT_FILE $OUTPUT_FILE.o $LIBRARY && echo ""
fi
 
if [ "$VERBOSE" == "True" ]; then
    echo "Linking finished"
fi
 
if [ "$QEMU" == "True" ]; then
    echo "Starting QEMU ..."
    echo ""
    if [ "$BITS" == "True" ]; then
        qemu-x86_64 $OUTPUT_FILE && echo ""
    else
        qemu-i386 $OUTPUT_FILE && echo ""
    fi
    exit 0
fi
 
if [ "$GDB" == "True" ]; then
    gdb_params=()
    gdb_params+=(-ex "b ${BREAK}")
    if [ "$RUN" == "True" ]; then
        gdb_params+=(-ex "r")
    fi
    gdb "${gdb_params[@]}" $OUTPUT_FILE
fi
