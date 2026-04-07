#!/bin/bash
#SBATCH --job-name=mpi_thread_test
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --time=00:02:00
#SBATCH --output=mpi_thread_test.out

set -e

# Write the test program
cat > /tmp/mpi_thread_test.c << 'EOF'
#include <stdio.h>
#include <mpi.h>

int main(int argc, char **argv) {
    int provided, rank;
    MPI_Init_thread(&argc, &argv, MPI_THREAD_MULTIPLE, &provided);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    if (rank == 0) {
        printf("Requested: MPI_THREAD_MULTIPLE (%d)\n", MPI_THREAD_MULTIPLE);
        printf("Provided:  %d\n", provided);
        if      (provided == MPI_THREAD_SINGLE)     printf("Level: MPI_THREAD_SINGLE\n");
        else if (provided == MPI_THREAD_FUNNELED)   printf("Level: MPI_THREAD_FUNNELED\n");
        else if (provided == MPI_THREAD_SERIALIZED) printf("Level: MPI_THREAD_SERIALIZED\n");
        else if (provided == MPI_THREAD_MULTIPLE)   printf("Level: MPI_THREAD_MULTIPLE  (OK for ELPA-GPU)\n");
        else                                        printf("Level: unknown\n");
    }
    MPI_Finalize();
    return 0;
}
EOF

mpicc /tmp/mpi_thread_test.c -o /tmp/mpi_thread_test
mpirun -n 2 /tmp/mpi_thread_test
