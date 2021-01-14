echo "Pre cli based actions ..."
userid=$(aws iam list-service-specific-credentials --user-name git-user | jq -r .ServiceSpecificCredentials[0].ServiceSpecificCredentialId)
if [ "$userid" != "null" ]; then
echo "destroying git user credentaisl for $userid"
aws iam delete-service-specific-credential --service-specific-credential-id $userid --user-name git-user
fi
# Empty codepipeline bucket ready for delete
buck=$(aws s3 ls | grep codep-tfeks | awk '{print $3}')
echo "buck=$buck"
if [ "$buck" != "" ]; then
echo "Emptying bucket $buck"
comm=$(printf "aws s3 rm s3://%s --recursive" $buck)
eval $comm
fi
#
# lb, lb sg, launch template
echo "pass 1 ...."
cur=`pwd`
date
dirs="extra/sampleapp2 extra/nodeg2 sampleapp cicd nodeg cluster c9net iam net"
for i in $dirs; do
cd ../$i
echo "**** Destroying in $i ****"
rm -rf .terrform*
terraform init
terraform destroy -auto-approve
cd $cur
date
done
echo "Pass 1 cli based actions ..."
echo "pass 2 ...."
dirs="sampleapp cicd nodeg cluster c9net iam net tf-setup"
for i in $dirs; do
cd ../$i
echo "**** Destroying in $i ****"
terraform destroy -auto-approve > /dev/null
rm -f tfplan
cd $cur
date
done

echo "Done"

exit