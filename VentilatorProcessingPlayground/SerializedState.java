class SerializedState
{
    public int SerializedHash;
    public int ComputedHash;

    public boolean IsValid()
    {
        return SerializedHash == ComputedHash;
    }
}
