namespace Queens {
//The general N-queen problem is to find the solution for placing N pieces on a NxN chessboard without any two of them being on the same column, row, or diagonal. 
//In this project, we try to solve the 4-queen problem with Grover's algorithm.
 
//We define four input states, where each one is made up of two qubits. The i-th state represents row of the position of the queen in the i-th column.
//First, we check if any two of the queens are on the same row. This is implemented by a circuit that checks if any pair of states are identical.
//Then, we check if any two of the queens are on the same diagonal. This is implemented by a circuit that checks if the index difference and the value difference of any pair of states are the same.

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
 
    operation checkRow(s1 : Qubit[], s2 : Qubit[],  output : Qubit) : Unit is Adj+Ctl {
        use ancillas = Qubit[2];
        Controlled X(s1[0..0], ancillas[0]);
        Controlled X(s2[0..0], ancillas[0]);
        Controlled X(s1[1..1], ancillas[1]);
        Controlled X(s1[1..1], ancillas[1]);
        X(ancillas[0]);
        X(ancillas[1]);
        Controlled X(ancillas, output); //flip output if s1 == s2
        X(ancillas[0]);
        X(ancillas[1]);
        Controlled X(s1[0..0], ancillas[0]);
        Controlled X(s2[0..0], ancillas[0]);
        Controlled X(s1[1..1], ancillas[1]);
        Controlled X(s1[1..1], ancillas[1]);
        
    }
    operation checkDiagonal(diff : Int, s1 : Qubit[], s2 : Qubit[],  output : Qubit) : Unit is Adj+Ctl {
        use ancillas = Qubit[2];
        if (diff == 1){
            X(ancillas[0]);
        }
        else if (diff == 2){
            X(ancillas[1]);
        }
        else if (diff == 3){
            X(ancillas[0]);
            X(ancillas[1]);
        }
        Controlled X(s1[0..0], ancillas[0]);
        Controlled X(s2[0..0], ancillas[0]);
        Controlled X(s1[1..1], ancillas[1]);
        Controlled X(s1[1..1], ancillas[1]);
        X(s1[0]);
        X(s2[0]);
        Controlled X([s1, s2], ancillas[0]);
        X(s1[0]);
        X(s2[0]);
        X(s1[1]);
        X(s2[1]);
        Controlled X([s1, s2], ancillas[1]);
        X(s1[1]);
        X(s2[1]);
        X(ancillas[0]);
        X(ancillas[1]);
        Controlled X(ancillas, output); //flip ouput if diff == abs(s1-s2)
        X(ancillas[0]);
        X(ancillas[1]);
        //uncomputing ancillas
        X(s1[1]);
        X(s2[1]);
        Controlled X([s1, s2], ancillas[1]);
        X(s1[1]);
        X(s2[1]);
        X(s1[0]);
        X(s2[0]);
        Controlled X([s1, s2], ancillas[0]);
        X(s1[0]);
        X(s2[0]);
        Controlled X(s1[0..0], ancillas[0]);
        Controlled X(s2[0..0], ancillas[0]);
        Controlled X(s1[1..1], ancillas[1]);
        Controlled X(s1[1..1], ancillas[1]);
        if (diff == 1){
            X(ancillas[0]);
        }
        else if (diff == 2){
            X(ancillas[1]);
        }
        else if (diff == 3){
            X(ancillas[0]);
            X(ancillas[1]);
        }

    }

    operation Oracle(inputs : Qubits[], output : Qubit) : Unit{
        use ancillas = Qubits[12]; //stores the results for checkRow and checkDiagonal
        mutable cnt = 0;
        for i in 0..3 {
            for j in i+1..3 {
                checkRow(inputs[i*2..i*2+1], inputs[j*2..j*2+1], ancillas[cnt]);
                cnt++;
                checkDiagonal(abs(i-j), inputs[i*2..i*2+1], inputs[j*2..j*2+1], ancillas[cnt]);
                cnt++;
            }
        }
        Controlled X(ancillas, output);
    }
    operation ConditionalPhaseFlip (register : Qubit[]) : Unit is Adj {
        for i in 0 .. Length(register)-1 {
            X(register[i]);
        }
        Controlled Z(register[0 .. Length(register)-2], register[Length(register)-1]);
        R(PauliI, 2.*3.14159, register[0]);
        for i in 0 .. Length(register)-1 {
            X(register[i]);
        }
}

    @EntryPoint()
    operation Grover() : Unit{
        use inputs = Qubit[8];
        use output = Qubit;

        X(output);
        H(output);
        Oracle(inputs, output);
        H(output);
        X(output);
        for i in 0..7{
            H(inputs[i]);
        }
        ConditionalPhaseFlip(inputs);
        for i in 0..7{
            H(inputs[i]);
        }
        let res = Measure([PauliZ], inputs);
        Message($"{res}");

    }
    
}

