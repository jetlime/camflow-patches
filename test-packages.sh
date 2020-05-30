for i in build/kernel/x86_64/kernel-*.rpm
do
	echo $i
  rpm -ivh --test $i
done
