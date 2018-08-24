
if pgrep mongo > /dev/null
then
    echo 'Killing mongo process'
    kill -2 `pgrep mongo`
    echo 'Mongo process killed'
else
    echo "No mongo process found"
fi
