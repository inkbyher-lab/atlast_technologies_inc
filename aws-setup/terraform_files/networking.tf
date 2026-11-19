resource "aws_vpc" "mainvpc"{
    cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.mainvpc.id 
}

resource "aws_eip" "eip"{
    domain = "vpc"
}

resource "aws_subnet" "public_subnet"{
    cidr_block = "10.10.0.0/24"
    vpc_id = aws_vpc.mainvpc.id
}

resource "aws_route_table" "public_rt"{
    vpc_id = aws_vpc.mainvpc.id 

    route {
        cidr_block = "0.0.0.0"
        gateway_id = aws_internet_gateway.igw.id 
    }
}

resource "aws_route_table_association" "pubrt_sub_association"{
    route_table_id = aws_route_table.public_rt.id 
    subnet_id = aws_subnet.public_subnet.id 
}

resource "aws_nat_gateway" "natgw"{
    subnet_id = aws_subnet.public_subnet.id 
    allocation_id = aws_eip.eip.id
}

resource "aws_subnet" "private_subnet"{
    cidr_block = "10.20.0.0/24"
    vpc_id = aws_vpc.mainvpc.id
}

resource "aws_route_table" "private_rt"{
    vpc_id = aws_vpc.mainvpc.id 

    route {
        cidr_block = "0.0.0.0"
        nat_gateway_id = aws_nat_gateway.natgw.id 
    }
}

resource "aws_route_table_association" "privatert_sub_association"{
    route_table_id = aws_route_table.private_rt.id 
    subnet_id = aws_subnet.private_subnet.id 
}