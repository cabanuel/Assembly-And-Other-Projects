import hashlib

print '*'*80
print 'WELCOME TO M&C BANK'
print '*'*80
print '\n'
mystring = str(input('ENTER 4 DIGIT PIN: \n'))
print '\n'

hash_object = '0fd600c953cde8121262e322ef09f70e'

pin = hashlib.md5(mystring.encode())

if pin.hexdigest() == hash_object:
    print '*'*80
    print 'CORRECT!!! YOU GET ALL THE MONEY!'
    print '\n'
else:
    print '*'*80
    print 'Hah. That was bad and you should feel bad.'
    print 'Goodbye Loser.'
    print '\n'
