# Arquitectura de un Microprocesador de 16 bits
### Microprocesador RISC de 16 bits.
Microprocesador de arquitectura RISC de 16 bits tipo MIPS (Microprocessor without Interlocked Pipeline Stages). La arquitectura MIPS es la base de los procesadores superescalares actuales, por lo que su estudio es fundamental para entender las arquitecturas de cómputo modernas. A este microprocesador le llamamos ESCOMIPS, el cual cuenta con una organización de seis componentes y cuenta con las siguientes características:
•	Formato de instrucción de 25 bits para todas las instrucciones. Los formatos son tipo R, I y J.
•	Cada instrucción se ejecuta en un ciclo de reloj.
•	Archivo de 16 registros de trabajo; es el banco de registros del procesador.
•	Pila en hardware de 8 niveles.
•	Memoria de programa y memoria de datos separada, es decir, Arquitectura Harvard. El contador de programa puede direccionar hasta 64kwords. En memoria de datos se puede direccionar hasta 64kwords+2kwords usando brincos relativos.
•	Ejecución de brincos condicionales en un solo ciclo de reloj.
