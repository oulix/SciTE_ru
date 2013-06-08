#encoding:utf8
# Detect file encoding
# Simple method that just chacks that first 1000 lines are valid in each encoding
# and chooses first from set that is valid for all lines checked.
# A better version would allow for a small proportion of failures and rank encodings
# depending on how well they match the input.
import sys 
import os

encodings = [ 
    ['utf-8', 65001, 0], 
    ['cp932', 932, 128],
    ['cp936', 936, 134],
    ['cp949', 949, 129],
    ['cp950', 950, 136],
]

codings = [e[0] for e in encodings]

def EncodingWorks(encoding, text):
    try:
        text.decode(encoding)
        return True
    except UnicodeDecodeError:
        return False
    
# Read up to first 1000 lines of file
if len(sys.argv) > 1 and os.path.isfile(sys.argv[1]):
    with open(sys.argv[1], "rb") as f:
        lineNumber = 1 
        for line in f.readlines():
            # Filter out any encodings that fail
            codings = [c for c in codings if EncodingWorks(c, line)]
            lineNumber += 1
            if lineNumber > 1000:
                break

codingsKnow = False

comment = ''
for c in codings:
    for e in encodings:
        if e[0] == c:
            codingsKnow = True
            codePage, characterSet = e[1:]
            if codePage:
                print('%scode.page=%s' % (comment, codePage))
            if characterSet:
                print('%scharacter.set=%s' % (comment, characterSet))
            # Display other matches as comments so can check results
            comment = '#' 
#如果检测不出文件的编码，将默认编码设置成cp936（GBK）
if codingsKnow==False:
    print 'code.page=936'
    print 'character.set=134'
# Change the caret colour so we can see that something happened
print('caret.fore=#4499FF')