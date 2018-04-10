/*
SubWCRev reads the Subversion status of all files in a
working copy, excluding externals. Then the highest revision
number found is used to replace all occurrences of "$""WCREV$"
in SrcVersionFile and the result is saved to DstVersionFile.
The commit date/time of the highest revision is used to replace
all occurrences of "$""WCDATE$". The modification status is used
to replace all occurrences of "$""WCMODS?TrueText:FalseText$" with
TrueText if there are local modifications, or FalseText if not.
*/

#define SVN_REV 21
#define SVN_DATE "2007/08/07 18:26:53"
#define SVN_MODS "Clean"
#define SVN_REVS "21"
