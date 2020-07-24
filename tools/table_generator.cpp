#include <stdarg.h>
#include <stdio.h>
#include <string.h>

typedef enum Exceptions
{
    EXCEPTION_Create_Error,
    EXCEPTION_Write_Error
} Exceptions;

const char *ProgramName;

const char *Filename = "lh5801_add_table.dart";

const char *Prologue = "// GENERATED CODE - DO NOT MODIFY BY HAND\n\n"
                       "class ALUResult {\n"
                       "  const ALUResult(this.value, this.flags);\n"
                       "  final int value, flags;\n"
                       "}\n\n";

const char *Epilogue = "\n";

#define FLAG_C 0x01
#define FLAG_Z 0x04
#define FLAG_V 0x08
#define FLAG_H 0x10

/*
 * Function:    Write
 *
 * Write formatted data to a file.
 *
 * Parameters:  Output file descriptor.
 *              Output format and variables arguments.
 *
 * Return:
 *
 * Exceptions:  EXCEPTION_Write_Error: write error.
 */
static void Write(FILE *file, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    if (vfprintf(file, format, args) <= 0)
    {
        va_end(args);
        fprintf(stderr, "%s: Error: Unable to write to '%s'\n", ProgramName, Filename);
        throw EXCEPTION_Write_Error;
    }
    va_end(args);
}

/*
 * Function:  GenerateAddTableAsArray
 *
 * Generate a table that store the values of the C, Z, V and H status bits
 * after an ADD or ADDC operation is performed.
 *
 * Parameters:  Output file descriptor.
 *
 * Return:
 *
 * Exceptions:  EXCEPTION_Create_Error: unable to create output file.
 *              EXCEPTION_Write_Error: write error.
 */
static void GenerateAddTableAsArray(FILE *file)
{
    const char *tablePrologue = "// index #1: op1, index #2: op2, index #3: carry\n"
                                "final List<List<List<ALUResult>>> addTable = <List<List<ALUResult>>>[\n";
    const char *index1Prologue = "  <List<ALUResult>>[\n";
    const char *index2Prologue = "    <ALUResult>[\n";
    const char *itemTemplate = "      const ALUResult(0x%02X, 0x%02X), // %02X %02X %d\n";
    const char *index2Epilogue = "    ],\n";
    const char *index1Epilogue = "  ],\n";
    const char *TableEpilogue = "];\n";

    try
    {
        Write(file, tablePrologue);
        for (unsigned int op1 = 0; op1 < 256; op1++)
        {
            Write(file, index1Prologue);
            for (unsigned int op2 = 0; op2 < 256; op2++)
            {
                Write(file, index2Prologue);
                for (unsigned int carry = 0; carry < 2; carry++)
                {
                    unsigned int result = op1 + op2 + carry;
                    int statusRegister = 0;

                    if ((result & 0xFF) == 0)
                    {
                        statusRegister |= FLAG_Z;
                    }
                    if ((result & 0x100) != 0)
                    {
                        statusRegister |= FLAG_C;
                    }
                    if (((op1 & 0x80) == ((op2 + carry) & 0x80)) && ((op1 & 0x80) != (result & 0x80)))
                    {
                        statusRegister |= FLAG_V;
                    }
                    if ((((op1 & 0x0F) + (op2 & 0x0F) + carry) & 0x10) != 0)
                    {
                        statusRegister |= FLAG_H;
                    }

                    Write(file, itemTemplate, result & 0xFF, statusRegister, op1, op2, carry);
                }
                Write(file, index2Epilogue);
            }
            Write(file, index1Epilogue);
        }
        Write(file, TableEpilogue);
    }
    catch (Exceptions e)
    {
        throw e;
    }
}

/*
 * Function:  GenerateAddTableAsMap
 *
 * Generate a table that store the values of the C, Z, V and H status bits
 * after an ADD or ADDC operation is performed.
 *
 * Parameters:  Output file descriptor.
 *
 * Return:
 *
 * Exceptions:  EXCEPTION_Create_Error: unable to create output file.
 *              EXCEPTION_Write_Error: write error.
 */
static void GenerateAddTableAsMap(FILE *file)
{
    const char *mapPrologue = "// ignore: avoid_positional_boolean_parameters\n"
                              "String generateTableKey(int op1, int op2, bool carry) {\n"
                              "  String _toHex(int value) => value.toUnsigned(8).toRadixString(16).padLeft(2, '0');\n"
                              "  return '${_toHex(op1)}_${_toHex(op2)}_${carry ? 1 : 0}'.toUpperCase();\n"
                              "}\n\n"
                              "// key: [op1]_[op2]_[carry]\n"
                              "final Map<String, ALUResult> addTable = <String, ALUResult>{\n";
    const char *itemTemplate = "  '%02X_%02X_%d': const ALUResult(0x%02X, 0x%02X),\n";
    const char *mapEpilogue = "};\n";

    try
    {
        Write(file, mapPrologue);

        for (unsigned int carry = 0; carry < 2; carry++)
        {
            for (unsigned int op1 = 0; op1 < 256; op1++)
            {
                for (unsigned int op2 = 0; op2 < 256; op2++)
                {
                    unsigned int result = op1 + op2 + carry;
                    int statusRegister = 0;

                    if ((result & 0xFF) == 0)
                    {
                        statusRegister |= FLAG_Z;
                    }
                    if ((result & 0x100) != 0)
                    {
                        statusRegister |= FLAG_C;
                    }
                    if (((op1 & 0x80) == ((op2 + carry) & 0x80)) && ((op1 & 0x80) != (result & 0x80)))
                    {
                        statusRegister |= FLAG_V;
                    }
                    if ((((op1 & 0x0F) + (op2 & 0x0F) + carry) & 0x10) != 0)
                    {
                        statusRegister |= FLAG_H;
                    }

                    Write(file, itemTemplate, op1, op2, carry, result & 0xFF, statusRegister);
                }
            }
        }
        Write(file, mapEpilogue);
    }
    catch (Exceptions e)
    {
        throw e;
    }
}

/*
 * Function:  main
 *
 * Entry point.
 *
 * Parameters:  An integer that contains the count of arguments that follow 
 *                in 'argv'.
 *              An array of null-terminated strings representing the com-
 *                mand-line arguments entered by the user of the program.
 *
 * Return:      False if success, otherwise true.
 *
 * Exceptions:
 */
int main(int argc, char *argv[])
{
    bool success = true;

    ProgramName = argv[0];
    try
    {
        fprintf(stderr, "Generating '%s'...\n", Filename);

        FILE *file = fopen(Filename, "w");
        if (file == 0L)
        {
            fprintf(stderr, "%s: Error: Unable to create '%s'\n", ProgramName, Filename);
            throw EXCEPTION_Create_Error;
        }

        Write(file, Prologue);
        // Array accesses seems to be about 6 times slower than map accesses...
        // GenerateAddTableAsArray(file);
        GenerateAddTableAsMap(file);
        Write(file, Epilogue);
        fclose(file);
    }
    catch (...)
    {
        success = false;
    }
    return !success;
}
