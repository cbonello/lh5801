#include <stdarg.h>
#include <stdio.h>
#include <string.h>

typedef enum Exceptions
{
    EXCEPTION_Create_Error,
    EXCEPTION_Write_Error
} Exceptions;

const char *gProgramName;

const char *prologue = "// GENERATED CODE - DO NOT MODIFY BY HAND\n\n"
                       "class ALUResult {\n"
                       "  const ALUResult(this.value, this.flags);\n"
                       "  final int value, flags;\n"
                       "}\n"
                       "\n"
                       "const int flagC = 0x01;\n"
                       "const int flagZ = 0x04;\n"
                       "const int flagV = 0x08;\n"
                       "const int flagH = 0x10;\n"
                       "\n"
                       "final Map<String, ALUResult> %s = <String, ALUResult>{\n";

const char *itemTemplate = "  '%02X_%02X_%d': const ALUResult(0x%02X, 0x%02X),\n";

const char *epilogue = "};\n";

#define FLAG_C 0x01
#define FLAG_Z 0x04
#define FLAG_V 0x08
#define FLAG_H 0x10

/****************************************************************************/
/* Function:	Dump														*/
/*																			*/
/* Print formatted data to a file.											*/
/*																			*/
/* Parameters:	Output file descriptor.										*/
/*				Output filename (to dump error messages).					*/
/*				Output format and variables arguments.						*/
/*																			*/
/* Return:																	*/
/*																			*/
/* Exceptions:	EXCEPTION_Write_Error: write error.							*/
/****************************************************************************/
static void Dump(FILE *file, const char *filename, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    if (vfprintf(file, format, args) <= 0)
    {
        va_end(args);
        fprintf(stderr, "%s: Error: Unable to write to '%s'\n", gProgramName, filename);
        throw EXCEPTION_Write_Error;
    }
    va_end(args);
}

/****************************************************************************/
/* Function:	GenerateAddTable											*/
/*																			*/
/* Generate a table that store the values of the C, Z, V and H status bits	*/
/* after an ADD or ADDC operation is performed. Table is stored in a '.h'	*/
/* file.																	*/
/*																			*/
/* Parameters:                              								*/
/*																			*/
/* Return:																	*/
/*																			*/
/* Exceptions:	EXCEPTION_Create_Error: unable to create output file.		*/
/*				EXCEPTION_Write_Error: write error.							*/
/****************************************************************************/
static void GenerateAddTable()
{
    const char *filename = "lh5801_add_table.dart";

    fprintf(stderr, "Generating '%s'...\n", filename);

    FILE *file = fopen(filename, "w");
    if (file == 0L)
    {
        fprintf(stderr, "%s: Error: Unable to create '%s'\n", gProgramName, filename);
        throw EXCEPTION_Create_Error;
    }

    try
    {
        Dump(file, filename, prologue, "addTable");

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

                    Dump(file, filename, itemTemplate, op1, op2, carry, result & 0xFF, statusRegister);
                }
            }
        }

        Dump(file, filename, epilogue);
        fclose(file);
    }
    catch (Exceptions e)
    {
        fclose(file);
        throw e;
    }
}

/****************************************************************************/
/* Function:	GenerateSubTable											*/
/*																			*/
/* Generate a table that store the values of the C, Z, V and H status bits	*/
/* after an SUB or SUBC operation is performed. Table is stored in a '.h'	*/
/* file.																	*/
/*																			*/
/* Parameters:                              								*/
/*																			*/
/* Return:																	*/
/*																			*/
/* Exceptions:	EXCEPTION_Create_Error: unable to create output file.		*/
/*				EXCEPTION_Write_Error: write error.							*/
/****************************************************************************/
static void GenerateSubTable()
{
    const char *filename = "lh5801_sbc_table.dart";

    fprintf(stderr, "Generating '%s'...\n", filename);

    FILE *file = fopen(filename, "w");
    if (file == 0L)
    {
        fprintf(stderr, "%s: Error: Unable to create '%s'\n", gProgramName, filename);
        throw EXCEPTION_Create_Error;
    }

    try
    {
        Dump(file, filename, prologue, "sbcTable");

        for (unsigned int carry = 0; carry < 2; carry++)
        {
            for (unsigned int op1 = 0; op1 <= 255; op1++)
            {
                for (unsigned int o2 = 0; o2 <= 255; o2++)
                {
                    unsigned int op2 = o2 ^ 0xFF;
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

                    Dump(file, filename, itemTemplate, op1, o2, carry, result & 0xFF, statusRegister);
                }
            }
        }

        Dump(file, filename, epilogue);
        fclose(file);
    }
    catch (Exceptions e)
    {
        fclose(file);
        throw e;
    }
}

/****************************************************************************/
/* Function:	main														*/
/*																			*/
/* Entry point.																*/
/*																			*/
/* Parameters:	An integer that contains the count of arguments that follow */
/*				  in 'argv'.												*/
/*				An array of null-terminated strings representing the com-	*/
/*				  mand-line arguments entered by the user of the program.	*/
/*																			*/
/* Return:		False if success, otherwise true.							*/
/*																			*/
/* Exceptions:																*/
/****************************************************************************/
int main(int argc, char *argv[])
{
    bool lSuccess = true;

    gProgramName = argv[0];
    try
    {
        GenerateAddTable();
        // GenerateSubTable();
    }
    catch (...)
    {
        lSuccess = false;
    }
    return !lSuccess;
}
