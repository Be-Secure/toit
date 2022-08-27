
import crypto.aes
import expect


/**
Randomly generated key with 256 bits.
Generated from https://www.allkeysgenerator.com/Random/Security-Encryption-Key-Generator.aspx.
*/
secret32 ::= #[
    0x45, 0x29, 0x48, 0x2B, 0x4D, 0x62, 0x51, 0x65, 
    0x54, 0x68, 0x57, 0x6D, 0x5A, 0x71, 0x34, 0x74,
    0x37, 0x77, 0x21, 0x7A, 0x25, 0x43, 0x2A, 0x46,
    0x2D, 0x4A, 0x61, 0x4E, 0x63, 0x52, 0x66, 0x55
]

//Use the lowest 192 bits of the 256 bit key
secret24 ::= secret32[0..24]

//Use the lowest 128 bits of the 256 bit key
secret16 ::= secret32[0..16]

/**
Random initialization vector.
Generated from: https://www.random.org/bytes/
*/
iv ::= #[
    0x3D, 0xB0, 0xE9, 0x41, 0xF9, 0x0B, 0x84, 0x79, 
    0x78, 0x72, 0xDC, 0xAA, 0x70, 0x4C, 0xff, 0x7D
]

//Plaintext 0..0xF
plaintext ::= ByteArray 16: it

/*
Precomputed ECB and CBC ciphertext with the specified key lengths
Results came from https://the-x.cn/en-us/cryptography/Aes.aspx.
*/
ecb_ciphertext16 ::= #[
    0x95, 0x42, 0x8A, 0xFB, 0xA1, 0x43, 0x57, 0x87, 
    0xFE, 0xCD, 0x40, 0xDE, 0x7A, 0x5A, 0xDB, 0xC9
]

ecb_ciphertext24 ::= #[
    0xF5, 0xF3, 0xB2, 0xB9, 0xD1, 0x4A, 0xD9, 0x94, 
    0xA7, 0xB6, 0xF8, 0x03, 0xD1, 0xE1, 0x65, 0xD6
]

ecb_ciphertext32 ::= #[
    0x4A, 0x10, 0x39, 0x90, 0xC6, 0xA8, 0xCA, 0xFB, 
    0x01, 0x3F, 0x3D, 0x39, 0x51, 0x9E, 0x22, 0xBD
]

cbc_ciphertext16 ::= #[
    0xE1, 0x44, 0xF2, 0x7F, 0xAF, 0x30, 0xD9, 0x12, 
    0x1D, 0x23, 0x4C, 0x62, 0x79, 0xDD, 0x81, 0xBE 
]

cbc_ciphertext24 ::= #[
    0xDA, 0x84, 0x55, 0x66, 0x53, 0xFF, 0x94, 0xA9, 
    0xAB, 0xC3, 0x29, 0x8A, 0x1A, 0x77, 0xA6, 0x1A
]

cbc_ciphertext32 ::= #[
    0xF8, 0x43, 0xEB, 0x13, 0x13, 0x45, 0xB1, 0xC4, 
    0x8B, 0x68, 0xD8, 0x6F, 0xF3, 0x64, 0xB9, 0x29
]

main:

    test_aes_cbc
    print "Test of AesCbc successfull"

    test_aes_ecb
    print "Test of AesEcb successfull"




test_aes_ecb:
    //Create AesEcb encryptor with 256 bit key
    encryptor /aes.AesEcb := aes.AesEcb.encryptor
        secret32

    //Create AesEcb decryptor with 256 bit key
    decryptor /aes.AesEcb := aes.AesEcb.decryptor
        secret32

    /*
    Test the encryption the plaintext with the encryptor
    and test that the result bytes are equal to the
    precomupted result stored in ecb_ciphertext32.
    */
    expect.expect_bytes_equal 
        ecb_ciphertext32
        (encryptor.encrypt plaintext)

    /*
    Test the decryption the ciphertext with the decryptor
    and test that the result bytes are equal to the
    original plaintext.
    */
    expect.expect_bytes_equal
        plaintext
        (decryptor.decrypt ecb_ciphertext32)
    
    //Repeat with 192 bit key
    encryptor = aes.AesEcb.encryptor
        secret24
    
    decryptor = aes.AesEcb.decryptor
        secret24
    
    expect.expect_bytes_equal 
        ecb_ciphertext24
        (encryptor.encrypt plaintext)

    expect.expect_bytes_equal
        plaintext
        (decryptor.decrypt ecb_ciphertext24)

    //Repeat with 128 bit key
    encryptor = aes.AesEcb.encryptor
        secret16
    
    decryptor = aes.AesEcb.decryptor
        secret16

    expect.expect_bytes_equal 
        ecb_ciphertext16
        (encryptor.encrypt plaintext)

    expect.expect_bytes_equal
        plaintext
        (decryptor.decrypt ecb_ciphertext16)

test_aes_cbc:
    //Create AesCbc encryptor with 256 bit key
    encryptor /aes.AesCbc := aes.AesCbc.encryptor
        secret32
        iv
    //Create AesCbc decryptor with 256 bit key
    decryptor /aes.AesCbc := aes.AesCbc.decryptor
        secret32
        iv

    /*
    Test the encryption the plaintext with the encryptor
    and test that the result bytes are equal to the
    precomupted result stored in cbc_ciphertext32.
    */
    expect.expect_bytes_equal 
        cbc_ciphertext32
        (encryptor.encrypt plaintext)

    /*
    Test the decryption the ciphertext with the decryptor
    and test that the result bytes are equal to the
    original plaintext.
    */
    expect.expect_bytes_equal
        plaintext
        (decryptor.decrypt cbc_ciphertext32)
    

    //Repeat with the 192 bit secret key
    encryptor = aes.AesCbc.encryptor
        secret24
        iv
    
    decryptor = aes.AesCbc.decryptor
        secret24
        iv
    
    expect.expect_bytes_equal 
        cbc_ciphertext24
        (encryptor.encrypt plaintext)

    expect.expect_bytes_equal
        plaintext
        (decryptor.decrypt cbc_ciphertext24)


    //Repeat with the 128 bit secret key
    encryptor = aes.AesCbc.encryptor
        secret16
        iv
    
    decryptor = aes.AesCbc.decryptor
        secret16
        iv

    expect.expect_bytes_equal 
        cbc_ciphertext16
        (encryptor.encrypt plaintext)

    expect.expect_bytes_equal
        plaintext
        (decryptor.decrypt cbc_ciphertext16)
    



