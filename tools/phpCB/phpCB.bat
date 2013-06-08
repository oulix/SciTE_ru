	"C:\Program Files\scite\tools\phpCB\phpCB.exe --space-after-start-bracket  --space-before-end-bracket --extra-padding-for-case-statement  --one-true-brace-function-declaration  --force-large-php-code-tag --indent-with-tab --force-true-false-null-contant-lowercase --comment-rendering-style PEAR " %1 > %1.phpcb	
	copy %1.phpcb %1
	del %1.phpcb
