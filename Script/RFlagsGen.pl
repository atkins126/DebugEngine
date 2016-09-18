
# Author = Mahdi Safsafi.

my $RFlagsType = 'TRFlags';
my $RFlagsHlp  = 'TRFlagsHlp';

my @rflags = qw/ID VIP VIF AC VM RF 0 NT 0 0 OF DF IF TF SF ZF 0 AF 0 PF 1 CF/;
@rflags = reverse @rflags;

open( F, '>', 'rflags.inc' );
print F "\n";
print F" { Do not edit ! => $RFlagsHlp was auto generated by $0 }\n";
print F"type\n  $RFlagsHlp = record helper for $RFlagsType\n  private\n";

foreach (@rflags) {
	next if (/0|1/);
	print F"    function Get$_:Boolean;\n";
	print F"    procedure Set$_(Value:Boolean);\n";
}
print F"    function GetIOPL:ShortInt;\n";
print F"    procedure SetIOPL(Value:ShortInt);\n";

print F"  public\n";
foreach (@rflags) {
	next if (/0|1/);
	my $propertyname = $_;
	$propertyname =~ s/^(if|of)/&$1/i;    # pascal reserved words.
	print F"    property $propertyname:Boolean read Get$_ write Set$_;\n";
}
print F"    property IOPL:ShortInt read GetIOPL write SetIOPL;\n";
print F"end;\n\n";
print F"{ $RFlagsHlp }\n\n";

my $i = -1;
foreach (@rflags) {
	$i++;
	next if (/0|1/);
	print F"function $RFlagsHlp.Get$_:Boolean;\n";
	print F"begin\n";
	my $mask = 1 << $i;
	printf F"  Result:= (Self and \$%.6X <> \$00);\n", $mask;
	print F"end;\n\n";

	print F"procedure $RFlagsHlp.Set$_ (Value:Boolean);\n";
	print F"begin\n";
	$mask = ~$mask;
	printf F
"  Self:= (Self and NativeUInt(\$%X)) or (NativeUInt(Value) shl \$%.2X);\n",
	  $mask, $i;
	print F"end;\n\n";

}

my $IOPL = <<"__@__";
function $RFlagsHlp.GetIOPL: ShortInt;
begin
  Result := (Self and \$003000) shr \$0C;
end;

procedure $RFlagsHlp.SetIOPL(Value: ShortInt);
begin
  Self := (Self and NativeUInt(\$FFFFFFFFFFFFCFFF)) or (NativeUInt(Value and \$03) shl \$0C);
end;
__@__

print F $IOPL;

close(F);
print "Done.\n";